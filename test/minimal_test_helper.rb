require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require 'test/unit'

$:.unshift File.dirname(File.dirname(__FILE__))
