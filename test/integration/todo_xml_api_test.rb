require 'test_helper'

class TodoXmlApiTest < ActionDispatch::IntegrationTest
  @@valid_postdata = "<todo><description>this will succeed</description><context_id type='integer'>10</context_id><project_id type='integer'>4</project_id></todo>"

  def setup
    @user = users(:admin_user)
    @password = 'abracadabra'
  end

  def test_get_tickler_succeeds
    authenticated_get_xml "/tickler.xml", @user.login, @password, {}
    assert_response 200
  end

  def test_get_tickler_needs_authentication
    get '/tickler.xml', {}, {}
    assert_response 401

    get "/tickler.xml", {}, {'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("wrong:wrong"),'ACCEPT' => 'application/xml'}
    assert_response 401
  end

  def test_get_tickler_returns_all_deferred_and_pending_todos
    number = @user.todos.deferred.count + @user.todos.pending.count
    authenticated_get_xml "/tickler.xml", @user.login, @password, {}
    assert_tag :tag => "todos", :children => { :count => number }
  end

  def test_get_tickler_omits_user_id
    authenticated_get_xml "/tickler.xml", @user.login, @password, {}
    assert_no_tag :tag => "user_id"
  end

  def test_get_index_with_only_active_todos
    authenticated_get_xml "/todos.xml", @user.login, @password, {}
    assert_response 200

    all_todo_count = assigns['xml_todos']

    authenticated_get_xml "/todos.xml?limit_to_active_todos=1", @user.login, @password, {}
    assert_response 200

    active_todo_count = assigns['xml_todos']
    assert all_todo_count != active_todo_count, "active should be less than all todos"
  end

  def test_create_todo_with_show_from
    old_count = @user.todos.count
    authenticated_post_xml_to_todo_create "
<todo>
  <description>Call Warren Buffet to find out how much he makes per day</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <show-from type=\"datetime\">#{1.week.from_now.xmlschema}</show-from>
</todo>"

    assert_response :success
    assert_equal @user.todos.count, old_count + 1
  end

  def test_post_create_todo_with_multiple_dependencies
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 2.0</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <predecessor_dependencies>
    <predecessor>5</predecessor>
    <predecessor>6</predecessor>
  </predecessor_dependencies>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 2.0").first
    assert_not_nil todo
    assert !todo.uncompleted_predecessors.empty?, "should have predecessors"
  end

  def test_post_create_todo_with_single_dependency
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 2.1</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <predecessor_dependencies>
    <predecessor>6</predecessor>
  </predecessor_dependencies>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 2.1").first
    assert_not_nil todo
    assert !todo.uncompleted_predecessors.empty?
  end

  def test_post_create_todo_with_multiple_tags
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 3</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <tags>
    <tag><name>starred</name></tag>
    <tag><name>starred1</name></tag>
    <tag><name>starred2</name></tag>
  </tags>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 3").first
    assert_not_nil todo
    assert_equal "starred, starred1, starred2", todo.tag_list
    assert todo.starred?
  end
  
  def test_post_create_todo_with_single_tag
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 3.1</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <tags>
    <tag><name>tracks</name></tag>
  </tags>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 3.1").first
    assert_not_nil todo
    assert_equal "tracks", todo.tag_list
  end

 def test_post_create_todo_with_multiple_tags_and_space
    # testing fix for #1229
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 3</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <tags>
    <tag><name>foo </name></tag>
    <tag><name> bar</name></tag>
    <tag><name>  bingo  </name></tag>
  </tags>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 3").first
    assert_not_nil todo
    assert_equal "bar, bingo, foo", todo.tag_list
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 4</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project_id>#{projects(:timemachine).id}</project_id>
  <tags>
    <tag><name>foo</name></tag>
    <tag><name>bar</name></tag>
    <tag><name>bingo</name></tag>
  </tags>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 4").first
    assert_not_nil todo
    assert_equal "bar, bingo, foo", todo.tag_list
  end
  
  def test_post_create_todo_with_new_context
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 4</description>
  <project_id>#{projects(:timemachine).id}</project_id>
  <context>
    <name>@SomeNewContext</name>
  </context>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 4").first
    assert_not_nil todo
    assert_not_nil todo.context
    assert_equal todo.context.name, "@SomeNewContext"
  end

  def test_post_create_todo_with_name_of_existing_context
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 4</description>
  <project_id>#{projects(:timemachine).id}</project_id>
  <context>
    <name>#{contexts(:office).name}</name>
  </context>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 4").first
    assert_not_nil todo
    assert_not_nil todo.context
    assert_equal contexts(:office).name, todo.context.name
  end


  def test_post_create_todo_with_new_project
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 5</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project>
    <name>Make even more money</name>
  </project>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 5").first
    assert_not_nil todo
    assert_not_nil todo.project
    assert_equal todo.project.name, "Make even more money"
  end

  def test_post_create_todo_with_name_of_existing_project
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will succeed 5</description>
  <context_id>#{contexts(:office).id}</context_id>
  <project>
    <name>#{projects(:timemachine).name}</name>
  </project>
</todo>"

    assert_response :success
    todo = @user.todos.where(:description => "this will succeed 5").first
    assert_not_nil todo
    assert_not_nil todo.project
    assert_equal projects(:timemachine).name, todo.project.name
    assert_equal 1, @user.projects.where("projects.name" => projects(:timemachine).name).count # no duplication of project
  end

  def test_post_create_todo_with_wrong_project_and_context_id
    authenticated_post_xml_to_todo_create "
<todo>
  <description>this will fail</description>
  <context_id type='integer'>-16</context_id>
  <project_id type='integer'>-11</project_id>
</todo>"
    assert_response 409
    assert_xml_select 'errors' do
      assert_select 'error', 2
    end
  end

  def test_fails_with_401_if_not_authorized_user
    authenticated_post_xml_to_todo_create '', 'nobody', 'nohow'
    assert_response 401
  end

  private

  def authenticated_post_xml_to_todo_create(postdata = @@valid_postdata, user = @user.login, password = @password)
    authenticated_post_xml "/todos.xml", user, password, postdata
  end

end