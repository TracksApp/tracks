ENV["RAILS_ENV"] ||= "test"
require 'mocha/setup'

$:.unshift File.dirname(File.dirname(__FILE__))
