ENV["RAILS_ENV"] ||= "test"
require 'minitest/autorun'
require 'mocha/setup'

$:.unshift File.dirname(File.dirname(__FILE__))
