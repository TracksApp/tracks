begin
  # Using PWD here instead of File.dirname(__FILE__) to be able to symlink to plugin
  # from within a Rails app.
  require File.expand_path(ENV['PWD'] + '/../../../spec/spec_helper')
rescue LoadError => e
  puts "You need to install rspec in your base app\n#{e.message}: #{e.backtrace.join("\n")}"
  exit
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
