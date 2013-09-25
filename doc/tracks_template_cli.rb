#!/usr/bin/env ruby

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

# Instantiate this template: ruby tracks_template_cli -c 1 -f template_file.txt

require 'optparse'
require 'cgi'
require 'readline'
require File.expand_path(File.dirname(__FILE__) + '/tracks_cli/tracks_api')

class TemplateParser

  def initialize
    @keywords = {}
  end

  def parse_keyword(token)
    print "Input required for "+token+": "
    @keywords[token]=gets.chomp
  end

  def replace_tokens_in(line)
    @keywords.each{ |key,val| line=line.sub(key,val) }
    line
  end

  def parse_todo(line)
    options = {}

    # first char is . or ^ the latter meaning this todo is dependent on the previous one
    options[:depend]= line[0].chr == "^" ? true : false;
    line = line[1..line.length] # remove first char

    tmp= line.split("|")
    if tmp.length > 5
      puts "Formatting error: found too many |"
      exit 1
    end

    tmp[0].chomp!
    options[:description]=tmp[0]

    tmp.each_with_index do |t,idx| 
      t=t.strip.chomp
      t=nil if t.empty?
      tmp[idx]=t
    end

    options[:context]=tmp[1]
    options[:taglist]=tmp[2]
    options[:notes]  =tmp[3]
    options
  end

  def parse(file, poster)
    while line = file.gets
      line = line.strip

      # skip line if empty or comment
      next if (line.empty? || line[0].chr == "#")

      # check if line defines a token
      if (line.split(' ')[0] == "token") 
        parse_keyword line.split(' ')[1] 
        next
      end

      # replace defined tokes in current line
      line = replace_tokens_in line

      # line is either todo/dependency or project
      if (line[0].chr == "." ) || (line[0].chr == "^")
        if @last_project_id.nil?
          puts "Warning: no project specified for task \"#{line}\". Using default project."
        end  
        poster.postTodo(parse_todo(line), @last_project_id)
      else
        @last_project_id = poster.postProject(line)
      end
    end
  end

end

class TemplatePoster

  def initialize(options)
    @options = options
    @tracks = TracksCli::TracksAPI.new({
      uri:            ENV['GTD_TODOS_URL'] || 'http://localhost:3000/todos.xml',
      login:          ENV['GTD_LOGIN'],
      password:       ENV['GTD_PASSWORD'],
      projects_uri:   ENV['GTD_PROJECTS_URL'] || 'http://localhost:3000/projects.xml',
      contexts_uri:   ENV['GTD_CONTEXT_URL'] || 'http://localhost:3000/contexts.xml',
      context_prefix: ENV['GTD_CONTEXT_URL_PREFIX'] || 'http://localhost:3000/contexts/'})
    @context_id = options[:context_id] ? options[:context_id].to_i : 1
    @project_id = options[:project_id] ? options[:project_id].to_i : 1
  end

  def postTodo(parsed_todo, project_id)
    resp = @tracks.post_todo(
      description:  CGI.escapeHTML(parsed_todo[:description]), 
      context_name: parsed_todo[:context], 
      context_id:   @context_id, 
      project_id:   project_id || @project_id, 
      show_from:    parsed_todo[:show_from],
      notes:        parsed_todo[:notes],
      is_dependend: parsed_todo[:depend],
      predecessor:  @last_posted_todo_id)

    if resp.code == '302' || resp.code == '201'
      puts resp['location'] if @options[:verbose]
      
      # return the todo id
      @last_posted_todo_id = resp['location'].split("/").last
      return @last_posted_todo_id
    else
      p resp.body
      raise Error
    end
  end

  def postProject(project_description)
    project_description.chomp!

    resp = @tracks.post_project(
      description:        CGI.escapeHTML(project_description),
      default_context_id: @context_id)

    if resp.code == '302' || resp.code == '201'
      puts resp['location'] if @options[:verbose]

      # return the project id
      return resp['location'].split("/").last
    else
      p resp.body
      raise Error
    end
  end

  def queryContext(context_id)
    return false unless context_id.is_a? Integer

    resp = @tracks.get_context(context_id)

    return resp.code == '200'
  end

end

class Error < StandardError; end
class InvalidParser < StandardError; end

class ConsoleOptionsForTemplate
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
    @poster = TemplatePoster.new(@options)

    if !@filename.nil? and not File.exist?(@filename)
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
    
    file = @filename.nil? ? STDIN : File.open(@filename)
    
    ## check for existence of the context
    if @options[:context_id].nil?
      puts "ERROR: need to specify a context_id with -c option."
      exit 1
    end

    if !@poster.queryContext(@options[:context_id])
      puts "Error: context_id #{options[:context_id]} doesn't exist"
      exit 1
    end

    TemplateParser.new.parse(file, @poster)

    exit 0
  rescue InvalidParser
    puts "Please specify a valid format parser."
    exit 1
  rescue Error
    puts "An unknown error occurred"
    exit 1
  end
end

if $0 == __FILE__
  ConsoleOptionsForTemplate.new.run(ARGV)
end
