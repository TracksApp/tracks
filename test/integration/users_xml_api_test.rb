require 'test_helper'

class UsersXmlApiTest < ActionDispatch::IntegrationTest
  
  @@foobar_postdata = "<user><login>foo</login><password>bar</password></user>"
  @@johnny_postdata = "<user><login>johnny</login><password>barracuda</password></user>"
  
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
   assert_response 400, "Expected response 400"
 end

 # Fails too hard for test to catch
 # def test_fails_with_invalid_xml_format
 #   authenticated_post_xml_to_user_create "<foo></bar>"
 #   assert_equal 500, @integration_session.status
 # end
    
  def test_fails_with_invalid_xml_format2
    authenticated_post_xml_to_user_create "<username>foo</username>"
    assert_response_and_body 400, "Expected post format is valid xml like so: <user><login>username</login><password>abc123</password></user>."
  end
  
  def test_xml_simple_param_parsing
    authenticated_post_xml_to_user_create
    assert @controller.params.has_key?(:user)
    assert @controller.params['user'].has_key?(:login)
    assert @controller.params['user'].has_key?(:password)
    assert_equal 'foo', @controller.params['user'][:login]
    assert_equal 'bar', @controller.params['user'][:password]
  end
  
  def test_fails_with_too_short_password
    authenticated_post_xml_to_user_create
    assert_responses_with_error "Password is too short (minimum is 5 characters"
  end
  
  def test_fails_with_nonunique_login
    existing_login = users(:other_user).login
    authenticated_post_xml_to_user_create "<user><login>#{existing_login}</login><password>barracuda</password></user>"
    assert_responses_with_error "Login has already been taken"
  end
  
  def test_creates_new_user
    assert_difference 'User.count' do
      authenticated_post_xml_to_user_create @@johnny_postdata
      assert_response_and_body 200, "User created."
    end
    johnny1 = User.where(:login => 'johnny').first
    assert_not_nil johnny1, "expected user johnny to be created"
    johnny2 = User.authenticate('johnny','barracuda')
    assert_not_nil johnny2, "expected user johnny to be authenticated"
  end
  
  def test_fails_with_get_verb
    authenticated_get_xml "/users.xml", users(:admin_user).login, 'abracadabra', {}
  end
  
  def test_get_users_as_xml
    get '/users.xml', {}, basic_auth_headers()
    assert_response :success
    assert_tag :tag => "users",
               :children => { :count => 4, :only => { :tag => "user" } }
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
    {'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}") }
  end

  def authenticated_post_xml_to_user_create(postdata = @@foobar_postdata, user = users(:admin_user).login, password = 'abracadabra', headers = {})
    authenticated_post_xml "/users.xml", user, password, postdata, headers
  end
end
