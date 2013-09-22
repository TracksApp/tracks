#!/usr/bin/env ruby

# CLI ruby client for Tracks: rails application for GTD methodology (First author: Vitalie Lazu <vitalie.lazu@gmail.com>)
# http://www.getontracks.org/development/
# You need to set ENV['GTD_LOGIN'], ENV['GTD_PASSWORD']
# and set GTD_TODOS_URL to your tracks install. It defaults to 'http://localhost:3000/todos.xml'
#
# Example:
# $ echo "todo 1\ntodo2" | GTD_LOGIN=username GTD_PASSWORD=secret ruby tracks_cli_client.rb -c 123 -p 456
# This will post todo 1 and todo 2 to localhost:3000 using username and secret als credentials

require 'optparse'
require 'cgi'
require File.expand_path(File.dirname(__FILE__) + '/tracks_cli/tracks_api')

class PostLineAsTodo

  def initialize(options)
    @options = options
    @tracks = TracksCli::TracksAPI.new(
      uri:      ENV['GTD_TODOS_URL'] || 'http://localhost:3000/todos.xml',
      login:    ENV['GTD_LOGIN'],
      password: ENV['GTD_PASSWORD'])
    @context_id = options[:context_id] ? options[:context_id].to_i : 1
    @project_id = options[:project_id] ? options[:project_id].to_i : 1
  end

  def post(lines)
    lines.each_line do |l|
      l.chomp!
      next if l.strip.empty?

      resp = @tracks.post_todo(
        description: CGI.escapeHTML(l),
        context_id:  @context_id, 
        project_id:  @project_id,
        show_from:   @options[:show_from])

      if resp.code == '302' || resp.code == '201'
        puts resp['location']
      else
        p resp.body
        raise Error
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

    PostLineAsTodo.new(@options).post(lines)
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
  ConsoleOptions.new.run(ARGV)
end
