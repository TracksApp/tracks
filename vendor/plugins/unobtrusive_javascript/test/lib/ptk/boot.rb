# We are always a test environment and should never be anything else
ENV["RAILS_ENV"] ||= "test"

require File.join(File.dirname(__FILE__), 'ptk')

# Set up RAILS_ROOT to #{plugin_path}/test
unless defined?(RAILS_ROOT)
  root_path = PTK::LoadPath.expand(__FILE__, '..', '..')
  
  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end
  
  RAILS_ROOT = root_path
end

# add #{plugin_path}/test/lib
PTK::LoadPath.add RAILS_ROOT, 'lib'

# add #{plugin_path}/lib
PTK::LoadPath.add RAILS_ROOT, '..', 'lib'

require 'rubygems'
require 'test/unit'
require 'active_support'