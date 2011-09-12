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

  def test_post_create_todo_with_wrong_project_and_context_id
    authenticated_post_xml_to_todo_create "<todo><description>this will fail</description><context_id type='integer'>-16</context_id><project_id type='integer'>-11</project_id></todo>"
    assert_response 422
    assert_xml_select 'errors' do
      assert_select 'error', 2
    end
  end

  private

  def authenticated_post_xml_to_todo_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/todos", user, password, postdata
  end

end