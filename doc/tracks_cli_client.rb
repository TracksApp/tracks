#!/usr/bin/env ruby

#
# Author: Vitalie Lazu <vitalie.lazu@gmail.com>
# Date: Sat, 10 Jan 2009 19:12:43 +0200
#

# CLI ruby client for Tracks: rails application for GTD methodology
# http://www.getontracks.org/development/
# You need to set ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
# and set GTD_TODOS_URL to your tracks install. It defaults to 'http://localhost:3000/todos.xml'

require 'net/https'
require 'optparse'
require 'cgi'
require 'time'

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
    GTD_URI = ENV['GTD_TODOS_URL'] || 'http://localhost:3000/todos.xml'

    def post(lines, options = {})
      uri = URI.parse(GTD_URI)
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs/" # Debian based path
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
      end

      lines.each_line do |l|
        l.chomp!
        next if l.strip.empty?

        description = CGI.escapeHTML(l)
        context_id = options[:context_id] ? options[:context_id].to_i : 1
        project_id = options[:project_id] ? options[:project_id].to_i : 1
        props = "<description>#{description}</description><project_id>#{project_id}</project_id><context_id>#{context_id}</context_id>"

        if options[:show_from]
          props << "<show-from type=\"datetime\">#{Time.at(options[:show_from]).xmlschema}</show-from>"
        end

        req = Net::HTTP::Post.new(uri.path, "Content-Type" => "text/xml")
        req.basic_auth ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
        req.body = "<todo>#{props}</todo>"

        resp = http.request(req)

        if resp.code == '302' || resp.code == '201'
          puts resp['location']
        else
          p resp.body
          raise Gtd::Error
        end
      end
    end
  end

  class Error < StandardError; end
  class InvalidParser < StandardError; end

  class ConsoleOptions
    attr_reader :parser, :options

    def initialize
      @options = {}

      @parser = OptionParser.new do |cmd|
        cmd.banner = "Ruby Gtd CLI - takes todos input from STDIN"

        cmd.separator ''

        cmd.on('-h', '--help', 'Displays this help message') do
          puts @parser
          exit
        end

        cmd.on('-p [N]', Integer, "project id to set for new todo") do |v|
          @options[:project_id] = v
        end

        cmd.on('-c [N]', Integer, 'context id to set') do |v|
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
      lines = STDIN.read

      if lines.strip.empty?
        puts "Please pipe in some content to tracks on STDIN."
        exit 1
      end

      gtd = API.new
      gtd.post(lines, @options)
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
