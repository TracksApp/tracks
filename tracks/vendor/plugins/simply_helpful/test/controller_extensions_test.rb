require File.dirname(__FILE__) + '/test_helper'
require 'ostruct'

class RedirectionTestingController < ActionController::Base
  class MockResponse
    attr_accessor :redirected_to
    
    def redirect(_)
    end
    
  end
  
  def initialize
    super
    @response = MockResponse.new
    @request = OpenStruct.new
    @request.protocol= "http://"
    @request.host_with_port= "www.example.com"
  end

  def response
    @response
  end
  
  def request
    @request
  end
  
  def post_url(p)
    "/posts/#{p.id}"
  end
  

end

class ControllerExtensionsTest < Test::Unit::TestCase
  def setup
    @record = Post.new
    @record.save
    @controller = RedirectionTestingController.new
  end
  
  def test_redirect_to_record
    @controller.send :redirect_to, @record
    assert_equal "http://www.example.com/posts/1", @controller.response.redirected_to
  end
  
  def test_redirect_to_string
    @controller.send :redirect_to, "http://www.yahoo.com"
    assert_equal "http://www.yahoo.com", @controller.response.redirected_to
  end
end