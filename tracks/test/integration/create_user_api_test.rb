require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'
require 'user'
require 'action_controller/integration'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class CreateUserControllerTest < ActionController::IntegrationTest
  fixtures :users
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", User.get_salt()
    @foobar_postdata = "<request><login>foo</login><password>bar</password></request>"
    @john_postdata = "<request><login>john</login><password>barracuda</password></request>"
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml '/user/create', 'nobody', 'nohow', @foobar_postdata
    assert_401_unauthorized
  end
  
 def test_fails_with_401_if_not_admin_user
   authenticated_post_xml '/user/create', users(:other_user).login, 'sesame', @foobar_postdata
   assert_401_unauthorized
 end
 
 def test_content_type_must_be_xml
   authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', @foobar_postdata, {'CONTENT_TYPE' => "application/x-www-form-urlencoded"}
   assert_response_and_body 404, "Content Type must be application/xml."
 end
  
 def test_fails_with_invalid_xml_format
   invalid_postdata = "<foo></bar>"
   authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', invalid_postdata
   assert_404_invalid_xml
 end
    
  def test_fails_with_invalid_xml_format2
    invalid_postdata = "<request><username>foo</username></request>"
    authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', invalid_postdata
    assert_404_invalid_xml
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', @foobar_postdata
    assert @controller.params.has_key?(:request)
    assert @controller.params[:request].has_key?(:login)
    assert @controller.params[:request].has_key?(:password)
    assert_equal 'foo', @controller.params[:request][:login]
    assert_equal 'bar', @controller.params[:request][:password]
  end
  
  def test_fails_with_too_short_password
    authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', @foobar_postdata
    assert_response_and_body 404, "Password is too short (minimum is 5 characters)"
  end
  
  def test_fails_with_nonunique_login
    existing_login = users(:other_user).login
    data = "<request><login>#{existing_login}</login><password>barracuda</password></request>"
    authenticated_post_xml "/user/create", users(:admin_user).login, 'abracadabra', data
    assert_response_and_body 404, "Login has already been taken"
  end
  
  def test_creates_new_user
    authenticated_post_xml '/user/create', users(:admin_user).login, 'abracadabra', @john_postdata
    assert_response_and_body 200, "User created."
    assert_equal 3, User.count
    john1 = User.find_by_login('john')
    assert_not_nil john1, "expected user john to be created"
    john2 = User.authenticate('john','barracuda')
    assert_not_nil john2, "expected user john to be created"
  end
  
  def test_fails_with_get_verb
    authenticated_get_xml "/user/create", users(:admin_user).login, 'abracadabra', {}
  end
    
  private
  
  def authenticated_post_xml(url, username, password, parameters, headers = {})
    post url,
        parameters,
        {'AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
          }.merge(headers)
  end

  def authenticated_get_xml(url, username, password, parameters, headers = {})
    get url,
        parameters,
        {'AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
          }.merge(headers)
  end

  def assert_401_unauthorized
    assert_response_and_body 401, "401 Unauthorized: You are not authorized to interact with Tracks."
  end

  def assert_404_invalid_xml
    assert_response_and_body 404, "Expected post format is xml like so: <request><login>username</login><password>abc123</password></request>."
  end

  def assert_response_and_body (type, body, message = nil)
    #puts @response.body
    assert_response type, message
    assert_equal body, @response.body, message
  end
  
end