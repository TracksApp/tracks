#!/usr/bin/env ruby

# Version 0.4 (Dec 17, 2011)

#
# Based on the tracks_cli by Vitalie Lazu (https://gist.github.com/45537)
#

# CLI ruby template  client for Tracks: rails application for GTD methodology
# https://github.com/TracksApp/tracks

# Usage:
# * You need to set ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
# * You need to pipe a file with new projets and actions to the script
# * You can use the -k option to customize templates. See the example below.
#
# Default URLs are:
#    ENV['GTD_TODOS_URL']          --> 'http://localhost:3000/todos.xml'
#    ENV['GTD_PROJECTS_URL']       --> 'http://localhost:3000/projects.xml'
#    ENV['GTD_CONTEXT_URL_PREFIX'] --> 'http://localhost:3000/contexts/'
#    ENV['GTD_CONTEXT_URL']        --> 'http://localhost:3000/contexts.xml'

# project := <name>
# dependent_action := ^<name>|context|<tag1>,..|<notes>
# independent_action := .<name>|context|<tag1>,..|<notes>
# to star an action add a tag 'starred'

# Format of input file:
# - A token to be replaced in the subsequent lines starts with the string token
# - New Projects start at the beginning of the line
# - New actions start with an '.' or an '^' at the beginning of the line.
# - To add a note to an action, separate the action from its note by using '|'. You have to stay in the same line.
# - Comments start with '#'

# Simple test file. Remove the '# ' string at the beginning.
# token [A]
# token [BB]
# 
# to [A] after [BB]
# .task 1 in [A], [BB]|computer|starred,blue|my notes here
# ^task 1.1 dependent on [A]|||only a note
# .task 2
# 
# project 2 with [A]
# .task in project 2

# Example of an input file. Remove the '# ' string at the beginning and save it in a file.
# token [location]
# token [start]
# token [end]
# Book trip to [location]
# .Check visa requirements for [location]|starred|instantiate template_visa, if visa required
# .Book flight to [location]||starting trip around [start], returning around [end]
# .Print flight details to [location]
# .Book hotel in [location]|checking around [start], leaving around [end]
# .Book rental car in [location]|starting [start], returning [end]
# .Print hotel booking details to [location]
# .Set email vacation reminder|starting [start], returning [end]; Text: I'm off for a vacation. I'll respond to emails after returning ([end]).
# .Mail others that I'll be away|starting [start], returning [end]
# Pack stuff for trip to [location]
# .Pack projector laptop adapter
# .Pack socket adapter for country ([location])
# .Pack passport
# .Pack flight and hotel detail printout
# Get trip reimbursement for [location]
# .Collect all [location] receipts in a clear plastic folder
# .Set a reminder to check for reimbursement for [location]
# .Mail folder to secretary

# Instantiate this template: ./tracks_template_cli -c 1 -f template_file.txt

require 'net/https'
require 'optparse'
require 'cgi'
require 'time'
require 'readline'

class Hash
  def to_query_string
    map { |k, v|
      if v.instance_of?(Hash)
        v.map { |sk, sv|
          "#{k}[#{sk}]=#{sv}"
        }.join('&')
      else
        "#{k}=#{v}"
      end
    }.join('&')
  end
end

module Gtd
  class API
    GTD_URI_TODOS = ENV['GTD_TODOS_URL'] || 'http://localhost:3000/todos.xml'
    GTD_URI_PROJECTS = ENV['GTD_PROJECTS_URL'] || 'http://localhost:3000/projects.xml'
    GTD_URI_CONTEXTS_PREFIX = ENV['GTD_CONTEXT_URL_PREFIX'] || 'http://localhost:3000/contexts/'
    GTD_URI_CONTEXTS = ENV['GTD_CONTEXT_URL'] || 'http://localhost:3000/contexts.xml'

    def postTodo(l, options = {})
      uri = URI.parse(GTD_URI_TODOS)
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs/" # Debian based path
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
      end

      l.chomp!

      description = CGI.escapeHTML(l)
      context_id = options[:context_id] ? options[:context_id].to_i : 1
      project_id = options[:project_id] ? options[:project_id].to_i : 1
      props = "<description>#{description}</description><project_id>#{project_id}</project_id>"

      if options[:show_from]
        props << "<show-from type=\"datetime\">#{Time.at(options[:show_from]).xmlschema}</show-from>"
      end

      if options[:note]
        props << "<notes>#{options[:note]}</notes>"
      end

      if options[:taglist]
        tags = options[:taglist].split(",")
        if tags.length() > 0
          tags = tags.collect { |tag| "<tag><name>#{tag.strip}</name></tag>" unless tag.strip.empty?}.join('')
          props << "<tags>#{tags}</tags>"
        end
      end

      if not (options[:context].nil? || options[:context].empty?)
        props << "<context><name>#{options[:context]}</name></context>"
      else
        ## use the default context
        props << "<context_id>#{context_id}</context_id>"
      end
      
      if options[:depend]
        props << "<predecessor_dependencies><predecessor>#{options[:last_todo_id]}</predecessor></predecessor_dependencies>"
      end

      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "text/xml")
      req.basic_auth ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
      req.body = "<todo>#{props}</todo>"

      puts req.body if options[:verbose]

      resp = http.request(req)

      if resp.code == '302' || resp.code == '201'
        puts resp['location'] if options[:verbose]
        
        # return the todo id
        return resp['location'].split("/").last
      else
        p resp.body
        raise Gtd::Error
      end
    end

    def postProject(l, options = {})
      uri = URI.parse(GTD_URI_PROJECTS)
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs/" # Debian based path
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
      end

      l.chomp!

      description = CGI.escapeHTML(l)
      props = "<name>#{l}</name><default-context-id>#{options[:context_id]}</default-context-id>"

      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "text/xml")
      req.basic_auth ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
      req.body = "<project>#{props}</project>"

      resp = http.request(req)

      if resp.code == '302' || resp.code == '201'
        puts resp['location'] if options[:verbose]

        # return the project id
        return resp['location'].split("/").last
      else
        p resp.body
        raise Gtd::Error
      end
    end

    def queryContext(contextID)
      return false unless contextID.is_a? Integer

      uri = URI.parse(GTD_URI_CONTEXTS_PREFIX + contextID.to_s + ".xml")
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs/" # Debian based path
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
      end

      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
      resp = http.request(req)

      case resp
      when Net::HTTPSuccess
        return true
      else
        return false
      end
    end

  end


  class Error < StandardError; end
  class InvalidParser < StandardError; end

  class ConsoleOptions
    attr_reader :parser, :options, :keywords

    def initialize
      @options = {}
      @keywords = {}

      @parser = OptionParser.new do |cmd|
        cmd.banner = "Ruby Gtd Templates CLI"

        cmd.separator ''

        cmd.on('-h', '--help', 'Displays this help message') do
          puts @parser
          exit
        end

        cmd.on('-p [N]', Integer, "project id to set for new todo") do |v|
          @options[:project_id] = v
        end

        cmd.on('-k [S]', "keyword to be replaced") do |v|
          @keywords[v.split("=")[0]] = v.split("=")[1]
        end

        cmd.on('-v', "verbose on") do |v|
          @options[:verbose] = true
        end

        cmd.on('-f [S]', "filename of the template") do |v|
          @filename = v
        end

        cmd.on('-c [N]', Integer, 'default context id to set for new projects') do |v|
          @options[:context_id] = v
        end

        cmd.on('-w [N]', Integer, 'Postpone task for N weeks') do |v|
          @options[:show_from] = Time.now.to_i + 24 * 3600 * 7 * (v || 1)
        end

        cmd.on('-m [N]', Integer, 'Postpone task for N months') do |v|
          @options[:show_from] = Time.now.to_i + 24 * 3600 * 7 * 4 * (v || 1)
        end
      end
    end

    def run(args)
      @parser.parse!(args)
      # lines = STDIN.read
      gtd = API.new

      if @filename != nil and not File.exist?(@filename)
        puts "ERROR: file #{@filename} doesn't exist"
        exit 1
      end

      if ENV['GTD_LOGIN'] == nil
        puts "ERROR: no GTD_LOGIN environment variable set"
        exit 1
      end
      
      if ENV['GTD_PASSWORD'] == nil
        puts "ERROR: no GTD_PASSWORD environment variable set"
        exit 1
      end
      
      if @filename == nil
        file = STDIN
      else
        file = File.open(@filename)
      end
      
      ## check for existence of the context
      if !@options[:context_id]
        puts "ERROR: need to specify a context_id with -c option. Go here to find one: #{API::GTD_URI_CONTEXTS}"
        exit 1
      end

      if !gtd.queryContext(@options[:context_id])
        puts "Error: context_id #{options[:context_id]} doesn't exist"
        exit 1
      end

      #lines.each_line do |line|
      while line = file.gets
        line = line.strip
        next if (line.empty? || line[0].chr == "#")

        if (line.split(' ')[0] == "token") 
          ## defining a new token; ask for input

          newtok=line.split(' ')[1]

          print "Input required for "+newtok+": "
          @keywords[newtok]=gets.chomp
          next
        end

        # replace tokens
        @keywords.each do |key,val|
          line=line.sub(key,val)
        end

        # decide whether project or task
        if (line[0].chr == "." ) || (line[0].chr == "^")
          @options[:depend]= line[0].chr == "^" ? true : false;
          line = line[1..line.length]

          # find notes
          tmp= line.split("|")
          if tmp.length > 5
            puts "Formatting error: found too many |"
            exit 1
          end

          line=tmp[0] 

          tmp.each_with_index do |t,idx| 
            t=t.strip.chomp
            t=nil if t.empty?
            tmp[idx]=t
          end

          @options[:context]=tmp[1]
          @options[:taglist]=tmp[2]
          @options[:note]=tmp[3]

          if !@options[:project_id]
            puts "Warning: no project specified for task \"#{line}\". Using default project."
          end

          @options[:last_todo_id]=gtd.postTodo(line, @options)
        else
          @options[:project_id]=gtd.postProject(line, @options)
        end
      end

      exit 0
    rescue InvalidParser
      puts "Please specify a valid format parser."
      exit 1
    rescue Error
      puts "An unknown error occurred"
      exit 1
    end
  end
end

if $0 == __FILE__
  app = Gtd::ConsoleOptions.new
  app.run(ARGV)
end
