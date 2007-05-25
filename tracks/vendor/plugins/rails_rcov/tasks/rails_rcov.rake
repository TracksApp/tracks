# This File Uses Magic
# ====================
# Here's an example of how this file works. As an example, let's say you typed
# this into your terminal:
# 
#   $ rake --tasks
# 
# The rake executable goes through all the various places .rake files can be,
# accumulates them all, and then runs them. When this file is loaded by Rake,
# it iterates through all the tasks, and for each task named 'test:blah' adds
# test:blah:rcov and test:blah:rcov_clobber.
# 
# So you've seen all the tasks, and you type this into your terminal:
# 
#   $ rake test:units:rcov
# 
# Rake does the same thing as above, but it runs the test:units:rcov task, which
# pretty much just does this:
# 
#   $ ruby [this file] [the test you want to run] [some options]
# 
# Now this file is run via the Ruby interpreter, and after glomming up the
# options, it acts just like the Rake executable, with a slight difference: it
# passes all the arguments to rcov, not ruby, so all your unit tests get some
# rcov sweet loving.

if ARGV.grep(/--run-rake-task=/).empty?
  # Define all our Rake tasks

  require 'rake/clean'
  require 'rcov/rcovtask'

  def to_rcov_task_sym(s)
    s = s.gsub(/(test:)/,'')
    s.empty? ? nil : s.intern
  end
  
  def to_rcov_task_name(s)
    s = s.gsub(/(test:)/,'')
    s =~ /s$/i ? s[0..-2] : s
  end
  
  def new_rcov_task(test_name)
    output_dir = "./coverage/#{test_name.gsub('test:','')}"
    CLOBBER.include(output_dir)
  
    # Add a task to run the rcov process
    desc "Run all #{to_rcov_task_name(test_name)} tests with Rcov to measure coverage"
    task :rcov => [:clobber_rcov] do |t|
      run_code = '"' << File.expand_path(__FILE__) << '"'
      run_code << " --run-rake-task=#{test_name}"
      
      params = String.new
      if ENV['RCOV_PARAMS']
        params << ENV['RCOV_PARAMS']
      end
      
      # rake test:units:rcov SHOW_ONLY=models,controllers,lib,helpers
      # rake test:units:rcov SHOW_ONLY=m,c,l,h
      if ENV['SHOW_ONLY']
        show_only = ENV['SHOW_ONLY'].to_s.split(',').map{|x|x.strip}
        if show_only.any?
          reg_exp = []
          for show_type in show_only
            reg_exp << case show_type
              when 'm', 'models' : 'app\/models'
              when 'c', 'controllers' : 'app\/controllers'
              when 'h', 'helpers' : 'app\/helpers'
              when 'l', 'lib' : 'lib'
              else
                show_type
            end
          end
          reg_exp.map!{ |m| "(#{m})" }
          params << " -x \\\"^(?!#{reg_exp.join('|')})\\\""
        end
      end
      
      unless params.empty?
        run_code << " --rcov-params=\"#{params}\""
      end

      ruby run_code
    end
    
    # Add a task to clean up after ourselves
    desc "Remove Rcov reports for #{to_rcov_task_name(test_name)} tests"
    task :clobber_rcov do |t|
      rm_r output_dir, :force => true
    end
    
    # Link our clobber task to the main one
    task :clobber => [:clobber_rcov]
  end
  
  test_tasks = Rake::Task.tasks.select{ |t| t.comment && t.name =~ /^test/ }
  for test_task in test_tasks
    namespace :test do
      if sym = to_rcov_task_sym(test_task.name)
        namespace sym do
          new_rcov_task(test_task.name)
        end
      end
    end
  end
else
  # Load rake tasks, hijack ruby, and redirect the task through rcov
  require 'rubygems'
  require 'rake'
  
  module RcovTestSettings
    class << self
      attr_accessor :output_dir, :options
      def to_params
        "-o \"#{@output_dir}\" -T -x \"rubygems/*,rcov*\" --rails #{@options}"
      end
    end
    
    # load options and arguments from command line
    unless (cmd_line = ARGV.grep(/--rcov-params=/)).empty?
      @options = cmd_line.first.gsub(/--rcov-params=/, '')
    end
  end
  
  def is_windows?
    processor, platform, *rest = RUBY_PLATFORM.split("-")
    platform == 'mswin32'
  end

  # intercept what Rake *would* be doing with Ruby, and send it through Rcov instead
  module RakeFileUtils
    alias :ruby_without_rcov :ruby
    def ruby(*args, &block)
      cmd = (is_windows? ? 'rcov.cmd' : 'rcov') << " #{RcovTestSettings.to_params} #{args}"
      status = sh(cmd, {}, &block)
      puts "View the full results at <file://#{RcovTestSettings.output_dir}/index.html>"
      return status
    end
  end
  
  # read the test name and execute it (through Rcov)
  unless (cmd_line = ARGV.grep(/--run-rake-task=/)).empty?
    test_name = cmd_line.first.gsub(/--run-rake-task=/,'')
    ARGV.clear; ARGV << test_name
    RcovTestSettings.output_dir = File.expand_path("./coverage/#{test_name.gsub('test:','')}")
    Rake.application.run
  else
    raise "No test to execute!"
  end
end