ENV["RAILS_ENV"] ||= "test"
require 'minitest/autorun'
require 'mocha/mini_test'

$:.unshift File.dirname(File.dirname(__FILE__))
