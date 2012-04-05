require 'test/unit'
require 'rubygems'
gem 'activesupport', '~> 2.3'
require 'active_support'
gem 'activerecord', '~> 2.3'
require 'active_record'
gem 'actionpack', '~> 2.3'
require 'active_support'
require 'action_view'
require 'action_controller'

#require File.dirname(__FILE__)+'/../../../../config/environment.rb'
require 'action_view/test_case'
require "action_controller/test_process"
require 'shoulda'
require File.dirname(__FILE__) + '/../init'

def assert_starts_with(start, what)
  assert what.starts_with?(start), "#{what} does not start with #{start}"
end
