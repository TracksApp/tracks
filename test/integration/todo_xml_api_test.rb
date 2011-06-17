require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'todos_controller'

class TodoXmlApiTest < ActionController::IntegrationTest
  fixtures :users, :contexts, :preferences, :todos
  
  def setup
    assert_test_environment_ok
    @user = users(:other_user)
    @password = 'sesame'
  end
  
  def test_get_tickler_succeeds
    authenticated_get_xml "/tickler", @user.login, @password, {}
    assert_response 200
  end
  
  def test_get_tickler_needs_authentication
    get '/tickler.xml', {}, {}
    assert_response 401

    get "/tickler", {}, {'AUTHORIZATION' => "Basic " + Base64.encode64("wrong:wrong"),'ACCEPT' => 'application/xml'}
    assert_response 401
  end
  
  def test_get_tickler_returns_all_deferred_todos
    number = @user.todos.deferred.count
    authenticated_get_xml "/tickler", @user.login, @password, {}
    assert_tag :tag => "todos", :children => { :count => number, :only => { :tag => "todo" } }
  end
  
  def test_get_tickler_omits_user_id
    authenticated_get_xml "/tickler", @user.login, @password, {}
    assert_no_tag :tag => "user_id"
  end
  
end