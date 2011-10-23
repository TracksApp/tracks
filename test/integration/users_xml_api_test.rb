require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersXmlApiTest < ActionController::IntegrationTest
  fixtures :users
  
  @@foobar_postdata = "<request><login>foo</login><password>bar</password></request>"
  @@johnny_postdata = "<request><login>johnny</login><password>barracuda</password></request>"
  
  def setup
    assert_test_environment_ok
  end
  
  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_user_create @@foobar_postdata, 'nobody', 'nohow'
    assert_401_unauthorized_admin
  end
  
 def test_fails_with_401_if_not_admin_user
   authenticated_post_xml_to_user_create @@foobar_postdata, users(:other_user).login, 'sesame'
   assert_401_unauthorized_admin
 end
 
 def test_content_type_must_be_xml
   authenticated_post_xml_to_user_create @@foobar_postdata, users(:admin_user).login, 'abracadabra', {'CONTENT_TYPE' => "application/x-www-form-urlencoded"}
   assert_404_invalid_xml
 end

 # Fails too hard for test to catch
 # def test_fails_with_invalid_xml_format
 #   authenticated_post_xml_to_user_create "<foo></bar>"
 #   assert_equal 500, @integration_session.status
 # end
    
  def test_fails_with_invalid_xml_format2
    authenticated_post_xml_to_user_create "<request><username>foo</username></request>"
    assert_404_invalid_xml
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_user_create
    assert @controller.params.has_key?(:request)
    assert @controller.params[:request].has_key?(:login)
    assert @controller.params[:request].has_key?(:password)
    assert_equal 'foo', @controller.params[:request][:login]
    assert_equal 'bar', @controller.params[:request][:password]
  end
  
  def test_fails_with_too_short_password
    authenticated_post_xml_to_user_create
    assert_response_and_body 404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Password is too short (minimum is 5 characters)</error>\n</errors>\n"
  end
  
  def test_fails_with_nonunique_login
    existing_login = users(:other_user).login
    authenticated_post_xml_to_user_create "<request><login>#{existing_login}</login><password>barracuda</password></request>"
    assert_response_and_body 404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Login has already been taken</error>\n</errors>\n"
  end
  
  def test_creates_new_user
    initial_count = User.count
    authenticated_post_xml_to_user_create @@johnny_postdata
    assert_response_and_body 200, "User created."
    assert_equal initial_count + 1, User.count
    johnny1 = User.find_by_login('johnny')
    assert_not_nil johnny1, "expected user johnny to be created"
    johnny2 = User.authenticate('johnny','barracuda')
    assert_not_nil johnny2, "expected user johnny to be created"
  end
  
  def test_fails_with_get_verb
    authenticated_get_xml "/users", users(:admin_user).login, 'abracadabra', {}
  end
  
  def test_get_users_as_xml
    get '/users.xml', {}, basic_auth_headers()
    assert_response :success
    assert_tag :tag => "users",
               :children => { :count => 5, :only => { :tag => "user" } }
    assert_no_tag :tag => "password"
  end

  def test_get_user_as_xml
    get "/users/#{users(:other_user).id}.xml", {}, basic_auth_headers()
    assert_response :success
    assert_tag :tag => "user"
    assert_no_tag :tag => "password"
  end
    
  private

  def basic_auth_headers(username = users(:admin_user).login, password = 'abracadabra')
    {'AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}") }
  end

  def authenticated_post_xml_to_user_create(postdata = @@foobar_postdata, user = users(:admin_user).login, password = 'abracadabra', headers = {})
    authenticated_post_xml "/users", user, password, postdata, headers
  end

  def assert_404_invalid_xml
    assert_response_and_body 404, "Expected post format is valid xml like so: <request><login>username</login><password>abc123</password></request>."
  end
  
end
