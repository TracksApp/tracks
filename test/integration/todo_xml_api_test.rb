require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'todos_controller'

class TodoXmlApiTest < ActionController::IntegrationTest
  fixtures :users, :contexts, :preferences, :todos, :projects

  @@valid_postdata = "<todo><description>this will succeed</description><context_id type='integer'>10</context_id><project_id type='integer'>4</project_id></todo>"

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
  
  def test_create_todo_via_xml_show_from
    old_count = @user.todos.count
    authenticated_post_xml_to_todo_create "
<todo>
  <description>Call Warren Buffet to find out how much he makes per day</description>
  <project_id>#{projects(:attendrailsconf).id}</project_id>
  <context_id>#{contexts(:office_otheruser).id}</context_id>
  <show-from type=\"datetime\">#{1.week.from_now.xmlschema}</show-from>
</todo>"

    assert_response :success
    assert_equal @user.todos.count, old_count + 1
  end
  
  def test_post_create_todo_with_dependencies
    old_count = @user.todos.count
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 2</description>
  <context_id type='integer'>10</context_id>
  <project_id type='integer'>4</project_id>
  <predecessor_dependencies>
    <predecessor>12</predecessor>
  </predecessor_dependencies>
  <successor_dependencies>
    <successor>12</successor>
  </successor_dependencies>
</todo>"

    assert_response :success
    assert_equal @user.todos.count, old_count + 1
  end
  
  def test_post_create_todo_with_tags
    old_count = @user.todos.count
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 2</description>
  <context_id type='integer'>10</context_id>
  <project_id type='integer'>4</project_id>
  <tags>
    <tag><name>starred</name></tag>
  </tags>
</todo>"

    puts @response.body
    assert_response :success
    assert_equal @user.todos.count, old_count + 1
  end

  def test_post_create_todo_with_wrong_project_and_context_id
    authenticated_post_xml_to_todo_create "<todo><description>this will fail</description><context_id type='integer'>-16</context_id><project_id type='integer'>-11</project_id></todo>"
    assert_response 422
    assert_xml_select 'errors' do
      assert_select 'error', 2
    end
  end
  
  def test_fails_with_401_if_not_authorized_user	 	
    authenticated_post_xml_to_todo_create '', 'nobody', 'nohow'
    assert_response 401
  end

  private

  def authenticated_post_xml_to_todo_create(postdata = @@valid_postdata, user = users(:other_user).login, password = 'sesame')
    authenticated_post_xml "/todos", user, password, postdata
  end

end