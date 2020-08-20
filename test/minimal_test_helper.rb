ENV["RAILS_ENV"] ||= "test"
require 'minitest/autorun'
require 'mocha/minitest'

$:.unshift File.dirname(File.dirname(__FILE__))
