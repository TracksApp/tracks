ENV["RAILS_ENV"] ||= "test"
require 'test/unit'
require 'mocha/setup'

$:.unshift File.dirname(File.dirname(__FILE__))
