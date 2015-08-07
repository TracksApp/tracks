require 'test_helper'

class TodosControllerTest < ActionController::TestCase

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to login_url
  end

  ############################
  # not done / deferred counts
  ############################

  def test_not_done_counts
    login_as(:admin_user)
    get :index
    assert_equal 2, projects(:timemachine).todos.active.count
    assert_equal 3, contexts(:call).todos.not_completed.count
    assert_equal 1, contexts(:lab).todos.not_completed.count
  end

  def test_cached_not_done_counts
    login_as(:admin_user)
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end

   def test_cached_not_done_counts_after_hiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    login_as(:admin_user)
    get :index
    assert_equal nil, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 2, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal nil, assigns['context_not_done_counts'][contexts(:lab).id]
  end

  def test_not_done_counts_after_hiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    login_as(:admin_user)
    get :index
    assert_equal 0, projects(:timemachine).todos.active.count
    assert_equal 2, contexts(:call).todos.active.count
    assert_equal 0, contexts(:lab).todos.active.count
  end

  def test_not_done_counts_after_hiding_and_unhiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    p.activate!
    p.save!
    login_as(:admin_user)
    get :index
    assert_equal 2, projects(:timemachine).todos.active.count
    assert_equal 3, contexts(:call).todos.not_completed.count
    assert_equal 1, contexts(:lab).todos.not_completed.count
  end

  def test_deferred_count_for_project_source_view
    login_as(:admin_user)
    xhr :post, :toggle_check, :id => 5, :_source_view => 'project'
    assert_equal 1, assigns['remaining_deferred_or_pending_count']
    xhr :post, :toggle_check, :id => 15, :_source_view => 'project'
    assert_equal 0, assigns['remaining_deferred_or_pending_count']
  end

  #########
  # tagging
  #########

  def test_tag_is_retrieved_properly
    login_as(:admin_user)
    get :index
    t = assigns['not_done_todos'].find{|t| t.id == 2}
    assert_equal 1, t.tags.count
    assert_equal 'foo', t.tags[0].name
    assert !t.starred?
  end

  def test_tagging_changes_to_tag_with_numbers
    # by default has_many_polymorph searches for tags with given id if the tag is a number. we do not want that
    login_as(:admin_user)
    assert_difference 'Todo.count' do
      put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
        "notes"=>"", "description"=>"test tags", "due"=>"30/11/2006"},
        "tag_list"=>"1234,5667,9876"
      # default has_many_polymorphs will fail on these high numbers as tags with those id's do not exist
    end
    t = assigns['todo']
    assert_equal t.description, "test tags"
    assert_equal 3, t.tags.count
  end

  def test_tagging_changes_to_handle_empty_tags
    # by default has_many_polymorph searches for tags with given id if the tag is a number. we do not want that
    login_as(:admin_user)
    assert_difference 'Todo.count' do
      put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
        "notes"=>"", "description"=>"test tags", "due"=>"30/11/2006"},
        "tag_list"=>"a,,b"
      # default has_many_polymorphs will fail on the empty tag
    end
    t = assigns['todo']
    assert_equal t.description, "test tags"
    assert_equal 2, t.tags.count
  end

  def test_find_tagged_with
    login_as(:admin_user)
    @user = User.find(@request.session['user_id'])
    tag = Tag.where(:name => 'foo').first.taggings
    @tagged = tag.count
    get :tag, :name => 'foo'
    assert_response :success
    assert_equal 3, @tagged
  end

  def test_find_tagged_with_terms_separated_with_dot
    login_as :admin_user
    create_todo(description: "test dotted tag", tag_list: "first.last, second")
    t = assigns['todo']
    assert_equal "first.last, second", t.tag_list

    get :tag, name: 'first.last.m'
    assert_equal "text/html", request.format, "controller should set right content type"
    assert_equal "text/html", @response.content_type
    assert_equal "first.last", assigns['tag_name'], ".m should be chomped"

    get :tag, name: 'first.last.txt'
    assert_equal "text/plain", request.format, "controller should set right content type"
    assert_equal "text/plain", @response.content_type
    assert_equal "first.last", assigns['tag_name'], ".txt should be chomped"

    get :tag, name: 'first.last'
    assert_equal "text/html", request.format, "controller should set right content type"
    assert_equal "text/html", @response.content_type
    assert_equal "first.last", assigns['tag_name'], ":name should be correct"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_single_tag
    login_as(:admin_user)
    get :tag, :name => "single"
    assert_equal true, assigns['single_tag'], "should recognize it is a single tag name"
    assert_equal "single", assigns['tag_expr'][0][0], "should store the single tag"
    assert_equal "single", assigns['tag_name'], "should store the single tag name"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_tags
    login_as(:admin_user)
    get :tag, :name => "multiple", :and => "tags", :and1 => "present", :and2 => "here"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 4, assigns['tag_expr'].size, "should have 4 AND expressions"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_tags_without_digitless_and
    login_as(:admin_user)
    get :tag, :name => "multiple", :and1 => "tags", :and2 => "present", :and3 => "here"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 4, assigns['tag_expr'].size, "should have 4 AND expressions"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_ORs
    login_as(:admin_user)
    get :tag, :name => "multiple,tags,present"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 1, assigns['tag_expr'].size, "should have 1 expressions"
    assert_equal 3, assigns['tag_expr'][0].size, "should have 3 ORs in 1st expression"
  end

  def test_get_boolean_expression_from_parameters_of_tag_view_multiple_ORs_and_ANDS
    login_as(:admin_user)
    get :tag, :name => "multiple,tags,present", :and => "here,is,two", :and1=>"and,three"
    assert_equal false, assigns['single_tag'], "should recognize it has multiple tags"
    assert_equal 3, assigns['tag_expr'].size, "should have 3 expressions"
    assert_equal 3, assigns['tag_expr'][0].size, "should have 3 ORs in 1st expression"
    assert_equal 3, assigns['tag_expr'][1].size, "should have 3 ORs in 2nd expression"
    assert_equal 2, assigns['tag_expr'][2].size, "should have 2 ORs in 3rd expression"
  end

  def test_set_right_title_tag_page
    login_as(:admin_user)

    get :tag, :name => "foo"
    assert_equal "foo", assigns['tag_title']
    get :tag, :name => "foo,bar", :and => "baz"
    assert_equal "foo,bar AND baz", assigns['tag_title']
  end

  def test_set_default_tag
    login_as(:admin_user)

    get :tag, :name => "foo"
    assert_equal "foo", assigns['initial_tags']
    get :tag, :name => "foo,bar", :and => "baz"
    assert_equal "foo", assigns['initial_tags']
  end

  ###############
  # creating todo
  ###############

  def test_create_todo
    assert_difference 'Todo.count' do
      login_as(:admin_user)
      put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    end
  end

  def test_create_todo_via_xml
    login_as(:admin_user)
    assert_difference 'Todo.count' do
      put :create, :format => "xml", "request" => { "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar" }
      assert_response 201
    end
  end

  def test_create_todo_via_xhr
    login_as(:admin_user)
    assert_difference 'Todo.count' do
      xhr :put, :create, "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
      assert_response 200
    end
  end

  def test_fail_to_create_todo_via_xml
    login_as(:admin_user)
    # try to create with no context, which is not valid
    put :create, :format => "xml", "request" => {
      "project_name"=>"Build a working time machine",
      "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar" }
    assert_response 409
    assert_xml_select "errors" do
      assert_xml_select "error", "Context can't be blank"
    end
  end

  def test_create_deferred_todo
    original_todo_count = Todo.count
    login_as(:admin_user)
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2026", 'show_from' => '30/10/2026'}, "tag_list"=>"foo bar"
    assert_equal original_todo_count + 1, Todo.count
  end

  def test_add_multiple_todos
    login_as(:admin_user)

    start_count = Todo.count
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
      :multiple_todos=>"a\nb\nmuch \"ado\" about \'nothing\'"}

    assert_equal start_count+3, Todo.count, "two todos should have been added"
  end

  def test_add_multiple_todos_with_validation_error
    login_as(:admin_user)

    long_string = "a" * 500

    start_count = Todo.count
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
      :multiple_todos=>"a\nb\nmuch \"ado\" about \'nothing\'\n#{long_string}"}

    assert_equal start_count, Todo.count, "no todos should have been added"
  end

  def test_add_multiple_dependent_todos
    login_as(:admin_user)

    start_count = Todo.count
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
      :multiple_todos=>"a\nb"}, :todos_sequential => 'true'
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
      :multiple_todos=>"c\nd"}, :todos_sequential => 'false'

    assert_equal start_count+4, Todo.count, "four todos should have been added"

    # find a,b,c and d
    %w{a b c d}.each do |todo|
      eval "@#{todo} = Todo.where(:description => '#{todo}').first"
      eval "assert !@#{todo}.nil?, 'a todo with description \"#{todo}\" should just have been added'"
    end

    assert @b.predecessors.include?(@a), "a should be a predeccesor of b"
    assert !@d.predecessors.include?(@c), "c should not be a predecessor of d"
  end

  #########
  # destroy
  #########

  def test_destroy_todo
    login_as(:admin_user)
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    todo = Todo.where(:id=>1).first
    assert_nil todo
  end

  ###############
  # edit / update
  ###############

  def test_get_edit_form_using_xhr
    login_as(:admin_user)
    xhr :get, :edit, :id => todos(:call_bill).id
    assert_response 200
  end

  def test_update_todo_project
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_equal 1, t.project_id
  end

  def test_update_todo_delete_project
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_nil t.project_id
  end

  def test_update_todo_to_deferred_is_reflected_in_badge_count
    login_as(:admin_user)
    get :index
    assert_equal 11, assigns['count']
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Make more money than Billy Gates", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006", "show_from"=>"30/11/2030"}, "tag_list"=>"foo bar"
    assert_equal 10, assigns['down_count']
  end

  def test_update_todo
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo, bar"
    t = Todo.find(1)
    assert_equal "Call Warren Buffet to find out how much he makes per day", t.description
    assert_equal "bar, foo", t.tag_list
    expected = Date.new(2006,11,30)
    actual = t.due.to_date
    assert_equal expected, actual, "Expected #{expected.to_s(:db)}, was #{actual.to_s(:db)}"
  end

  def test_update_todos_with_blank_project_name
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', :project_name => '', "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo, bar"
    t.reload
    assert t.project.nil?
  end

  def test_update_todo_tags_to_none
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>""
    t = Todo.find(1)
    assert_equal true, t.tag_list.empty?
  end

  def test_update_todo_tags_with_whitespace_and_dots
    t = Todo.find(1)
    login_as(:admin_user)
    taglist = "  one  ,  two,three    ,four, 8.1.2, version1.5"
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>taglist
    t = Todo.find(1)
    assert_equal "8.1.2, four, one, three, two, version1.5", t.tag_list
  end

  def test_removing_hidden_project_activates_todo
    login_as(:admin_user)

    # get a project and hide it, todos in the project should be hidden
    p = projects(:timemachine)
    p.hide!
    assert p.reload().hidden?
    todo = p.todos.first

    assert todo.project_hidden?, "todo should be project_hidden"

    # clear project from todo: the todo should be unhidden
    xhr :post, :update, :id => todo.id, :_source_view => 'todo', "project_name"=>"", "todo"=>{}

    assert assigns['project_changed'], "the project of the todo should be changed"
    todo = Todo.find(todo.id) # reload does not seem to work anymore
    assert todo.active?, "todo should be active"
  end

  def test_change_context_of_todo
    # called by dragging a todo to another context container
    login_as(:admin_user)

    todo = users(:admin_user).todos.active.first
    context = users(:admin_user).contexts.first

    assert_not_equal todo.context.id, context.id

    xhr :post, :change_context, :id => todo.id, :todo=>{:context_id => context.id}, :_source_view=>"todo"
    assert assigns['context_changed'], "context should have changed"
    assert_equal todo.id, assigns['todo'].id, 'correct todo should have been found'
    assert_equal context.id, todo.reload.context.id, 'context of todo should be changed'
  end

  #######
  # defer
  #######

  def test_update_clearing_show_from_makes_todo_active
    t = Todo.find(1)
    t.show_from = "01/01/2030"
    assert t.deferred?
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"show_from"=>""}, "tag_list"=>""
    t = Todo.find(1)
    assert t.active?
    assert_nil t.show_from
  end

  def test_update_setting_show_from_makes_todo_deferred
    t = Todo.find(1)
    assert t.active?
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "todo"=>{"show_from"=>"01/01/2030"}, "tag_list"=>""
    t = Todo.find(1)
    assert t.deferred?
    assert_not_nil t.show_from
  end

  def test_find_and_activate_ready
    login_as(:admin_user)

    # given a todo in the tickler that should be activated
    travel_to 2.weeks.ago do
      create_todo(
        description: "tickler",
        show_from: 1.week.from_now.
          in_time_zone(users(:admin_user).prefs.time_zone).
          strftime("#{users(:admin_user).prefs.date_format}"))
    end

    todos = Todo.where(description: "tickler").where('show_from < ?', Time.zone.now)
    assert_equal 1, todos.count, "there should be one todo in tickler"
    todo = todos.first

    assert todo.deferred?, "todo should be in deferred state"

    # index page calls find_and_activate_ready
    get :index

    todo.reload
    assert todo.active?, "todo should have been activated"
    assert todo.show_from.nil?, "show_from date should have been cleared"
  end

  #######
  # feeds
  #######

  def test_rss_feed
    login_as(:admin_user)
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml', @response.content_type
    # puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Tracks Actions'
        assert_select '>description', "Actions for #{users(:admin_user).display_name}"
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
        assert_select 'item', 17 do
          assert_select 'title', /.+/
          assert_select 'description', /.*/
          assert_select 'link', %r{http://test.host/contexts/.+}
          assert_select 'guid', %r{http://test.host/todos/.+}
          assert_select 'pubDate', todos(:book).updated_at.to_s(:rfc822)
        end
      end
    end
  end

  def test_rss_feed_with_limit
    login_as(:admin_user)
    get :index, { :format => "rss", :limit => '5' }

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Tracks Actions'
        assert_select '>description', "Actions for #{users(:admin_user).display_name}"
        assert_select 'item', 5 do
          assert_select 'title', /.+/
          assert_select 'description', /.*/
        end
      end
    end
  end

  def test_rss_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "rss" }
    assert_response 401
  end

  def test_rss_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "rss", :token => 'foo'  }
    assert_response 401
  end

  def test_rss_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "rss", :token => users(:admin_user).token }
    assert_response :ok
  end

  def test_atom_feed_content
    login_as :admin_user
    get :index, { :format => "atom" }
    assert_equal 'application/atom+xml', @response.content_type
    # #puts @response.body

    assert_xml_select 'feed[xmlns="http://www.w3.org/2005/Atom"]' do
      assert_xml_select '>title', 'Tracks Actions'
      assert_xml_select '>subtitle', "Actions for #{users(:admin_user).display_name}"
      assert_xml_select 'entry', 17 do
        assert_xml_select 'title', /.+/
        assert_xml_select 'content[type="html"]', /.*/
        assert_xml_select 'published', /(#{Regexp.escape(todos(:book).updated_at.xmlschema)}|#{Regexp.escape(projects(:moremoney).updated_at.xmlschema)})/
      end
    end
  end

  def test_atom_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "atom" }
    assert_response 401
  end

  def test_atom_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "atom", :token => 'foo'  }
    assert_response 401
  end

  def test_atom_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "atom", :token => users(:admin_user).token }
    assert_response :ok
  end

  def test_text_feed_content
    login_as(:admin_user)
    get :index, { :format => "txt" }
    assert_equal 'text/plain', @response.content_type
    assert !(/&nbsp;/.match(@response.body))
    # #puts @response.body
  end

  def test_text_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :index, { :format => "txt" }
    assert_response 401
  end

  def test_text_feed_not_accessible_to_anonymous_user_with_invalid_token
    login_as nil
    get :index, { :format => "txt", :token => 'foo'  }
    assert_response 401
  end

  def test_text_feed_accessible_to_anonymous_user_with_valid_token
    login_as nil
    get :index, { :format => "txt", :token => users(:admin_user).token }
    assert_response :ok
  end

  def test_ical_feed_content
    login_as :admin_user
    get :index, { :format => "ics" }
    assert_equal 'text/calendar', @response.content_type
    assert !(/&nbsp;/.match(@response.body))
    # #puts @response.body
  end

  def test_tag_text_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :tag, {:name => "foo", :format => "txt" }
    assert_response 401
  end

  ##############
  # mobile index
  ##############

  def test_mobile_index_uses_text_html_content_type
    login_as(:admin_user)
    get :index, { :format => "m" }
    assert_equal 'text/html', @response.content_type
  end

  def test_mobile_index_assigns_down_count
    login_as(:admin_user)
    get :index, { :format => "m" }
    assert_equal 11, assigns['down_count']
  end

  def test_mobile_redirect_to_login
    get :index, { :format => "m" }
    assert_redirected_to login_url(:format => "m")
  end

  ###############
  # mobile create
  ###############

  def test_mobile_create_action_creates_a_new_todo
    login_as(:admin_user)
    post :create, {"format"=>"m", "todo"=>{"context_id"=>"2",
        "due(1i)"=>"2007", "due(2i)"=>"1", "due(3i)"=>"2",
        "show_from(1i)"=>"", "show_from(2i)"=>"", "show_from(3i)"=>"",
        "project_id"=>"1",
        "notes"=>"test notes", "description"=>"test_mobile_create_action"}}
    t = Todo.where(:description => "test_mobile_create_action").first
    assert_not_nil t
    assert_equal 2, t.context_id
    assert_equal 1, t.project_id
    assert t.active?
    assert_equal 'test notes', t.notes
    assert_nil t.show_from
    assert_equal Date.new(2007,1,2), t.due.to_date
  end

  def test_mobile_create_action_redirects_to_mobile_home_page_when_successful
    login_as(:admin_user)
    post :create, {"format"=>"m", "todo"=>{"context_id"=>"2",
        "due(1i)"=>"2007", "due(2i)"=>"1", "due(3i)"=>"2",
        "show_from(1i)"=>"", "show_from(2i)"=>"", "show_from(3i)"=>"",
        "project_id"=>"1",
        "notes"=>"test notes", "description"=>"test_mobile_create_action"}}

    assert_redirected_to '/mobile'
  end

  def test_mobile_create_action_renders_new_template_when_save_fails
    login_as(:admin_user)
    post :create, {"format"=>"m", "todo"=>{"context_id"=>"2",
        "due(1i)"=>"2007", "due(2i)"=>"1", "due(3i)"=>"2",
        "show_from(1i)"=>"", "show_from(2i)"=>"", "show_from(3i)"=>"",
        "project_id"=>"1",
        "notes"=>"test notes"}, "tag_list"=>"test, test2"}
    assert_template 'todos/new'
  end

  ################
  # recurring todo
  ################

  def test_toggle_check_on_recurring_todo
    login_as(:admin_user)

    # link todo_1 and recurring_todo_1
    recurring_todo_1 = RecurringTodo.find(1)
    todo_1 = Todo.where(:recurring_todo_id => 1).first

    # mark todo_1 as complete by toggle_check
    xhr :post, :toggle_check, :id => todo_1.id, :_source_view => 'todo'
    todo_1.reload
    assert todo_1.completed?

    # check that there is only one active todo belonging to recurring_todo
    count = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'active').count
    assert_equal 1, count

    # check there is a new todo linked to the recurrence pattern
    next_todo = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'active').first
    assert_equal "Call Bill Gates every day", next_todo.description
    # check that the new todo is not the same as todo_1
    assert_not_equal todo_1.id, next_todo.id

    # change recurrence pattern to monthly and set show_from 2 days before due
    # date this forces the next todo to be put in the tickler
    recurring_todo_1.show_from_delta = 2
    recurring_todo_1.show_always = 0
    recurring_todo_1.target = 'due_date'
    recurring_todo_1.recurring_period = 'monthly'
    recurring_todo_1.recurrence_selector = 0
    recurring_todo_1.every_other1 = 1
    recurring_todo_1.every_other2 = 2
    recurring_todo_1.every_other3 = 5
    # use assert to catch validation errors if present. we need to replace
    # this with a good factory implementation
    assert recurring_todo_1.save

    # mark next_todo as complete by toggle_check
    xhr :post, :toggle_check, :id => next_todo.id, :_source_view => 'todo'
    next_todo.reload
    assert next_todo.completed?

    # check that there are three todos belonging to recurring_todo: two
    # completed and one deferred
    count = Todo.where(:recurring_todo_id => recurring_todo_1.id).count
    assert_equal 3, count

    # check there is a new todo linked to the recurrence pattern in the tickler
    next_todo = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'deferred').first
    assert !next_todo.nil?
    assert_equal "Call Bill Gates every day", next_todo.description
    # check that the todo is in the tickler
    assert !next_todo.show_from.nil?
  end

  def test_toggle_check_on_rec_todo_show_from_today
    # warning: the Time.zone set in site.yml will be overwritten by
    # :admin_user.prefs.time_zone in ApplicationController. This messes with
    # the calculation. So set time_zone to admin_user's time_zone setting
    Time.zone = users(:admin_user).prefs.time_zone

    travel_to Time.zone.local(2014, 1, 15) do
      today = Time.zone.now.at_midnight

      login_as(:admin_user)

      # link todo_1 and recurring_todo_1
      recurring_todo_1 = RecurringTodo.find(1)
      todo_1 = Todo.where(:recurring_todo_id => 1).first
      todo_1.due = today
      assert todo_1.save

      # change recurrence pattern to monthly on a specific
      # day (recurrence_selector=0) and set show_from
      # (every_other2=1) to today
      recurring_todo_1.target = 'show_from_date'
      recurring_todo_1.recurring_period = 'monthly'
      recurring_todo_1.recurrence_selector = 0
      recurring_todo_1.every_other1 = today.day
      recurring_todo_1.every_other2 = 1
      assert recurring_todo_1.save

      # mark todo_1 as complete by toggle_check
      xhr :post, :toggle_check, :id => todo_1.id, :_source_view => 'todo'
      todo_1.reload
      assert todo_1.completed?

      # locate the new todo in tickler
      new_todo = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'deferred').first
      assert !new_todo.nil?, "the todo should be in the tickler"

      assert_equal "Call Bill Gates every day", new_todo.description
      assert_not_equal todo_1.id, new_todo.id, "check that the new todo is not the same as todo_1"
      assert !new_todo.show_from.nil?, "check that the new_todo is in the tickler to show next month"

      assert_equal today + 1.month, new_todo.show_from
    end
  end

  def test_check_for_next_todo
    login_as :admin_user
    Time.zone = users(:admin_user).prefs.time_zone

    tomorrow = Time.zone.now + 1.day

    # Given a recurrence pattern with recurring date set to tomorrow
    recurring_todo_1 = RecurringTodo.find(5)
    recurring_todo_1.every_other1 = tomorrow.day
    recurring_todo_1.every_other2 = tomorrow.month
    recurring_todo_1.save

    # Given a recurring todo (todo) that belongs to the recurrence pattern (recurring_todo_1) and is due tomorrow
    todo = Todo.where(:recurring_todo_id => 1).first
    assert todo.from_recurring_todo?
    todo.recurring_todo_id = 5 # rewire todo to the recurrence pattern above
    todo.due = tomorrow
    todo.save!

    # When I mark the todo complete
    xhr :post, :toggle_check, :id => todo.id, :_source_view => 'todo'
    todo = Todo.find(todo.id) #reload does not seem to work here
    assert todo.completed?

    # Then there should not be an active todo belonging to the recurrence pattern
    next_todo = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'active').first
    assert next_todo.nil?

    # Then there should be one new deferred todo
    next_todo = Todo.where(:recurring_todo_id => recurring_todo_1.id, :state => 'deferred').first
    assert !next_todo.nil?
    assert !next_todo.show_from.nil?

    # check that the due date of the new todo is later than tomorrow
    assert next_todo.due > todo.due
  end

  def test_check_for_next_todo_monthly
    login_as :admin_user
    Time.zone = users(:admin_user).prefs.time_zone

    tomorrow = Time.zone.now + 1.day

    # Given a monthly recurrence pattern
    recurring_todo = RecurringTodo.find(5)
    recurring_todo.target = "due_date"
    recurring_todo.recurring_period = "monthly"
    recurring_todo.every_other1 = tomorrow.day
    recurring_todo.every_other2 = 1
    recurring_todo.save

    # Given a recurring todo (todo) that belongs to the recurrence pattern (recurring_todo) and is due tomorrow
    todo = Todo.where(:recurring_todo_id => 1).first
    assert todo.from_recurring_todo?
    todo.recurring_todo_id = 5 # rewire todo to the recurrence pattern above
    todo.due = tomorrow
    todo.save!

    # When I mark the todo complete
    xhr :post, :toggle_check, :id => todo.id, :_source_view => 'todo'
    todo.reload
    assert todo.completed?

    # Then there should not be an active todo belonging to the recurrence pattern
    next_todo = Todo.where(:recurring_todo_id => recurring_todo.id, :state => 'active').first
    assert next_todo.nil?

    # Then there should be one new deferred todo
    next_todo = Todo.where(:recurring_todo_id => recurring_todo.id, :state => 'deferred').first
    assert !next_todo.nil?
    assert !next_todo.show_from.nil?

    # check that the due date of the new todo is later than tomorrow
    assert next_todo.due > todo.due
  end

  ############
  # todo notes
  ############

  def test_url_with_slash_in_query_string_are_parsed_correctly
    # See http://blog.swivel.com/code/2009/06/rails-auto_link-and-certain-query-strings.html
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    url = "http://example.com/foo?bar=/baz"
    todo.notes = "foo #{url} bar"
    todo.save!
    get :index
    assert_select("a[href=#{url}]")
  end

  def test_format_note_normal
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    todo.notes = "A normal description."
    todo.save!
    get :index
    assert_select("div#notes_todo_#{todo.id}", "A normal description.")
  end

  def test_format_note_textile
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    todo.notes = "A *bold description*."
    todo.save!
    get :index
    assert_select("div#notes_todo_#{todo.id}", "A bold description.")
    assert_select("div#notes_todo_#{todo.id} strong", "bold description")
  end

  def test_format_note_link
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    todo.notes = "A link to http://github.com/."
    todo.save!
    get :index
    assert_select("div#notes_todo_#{todo.id}", 'A link to http://github.com/.')
    assert_select("div#notes_todo_#{todo.id} a[href=http://github.com/]", 'http://github.com/')
  end

  def test_format_note_link_message
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    todo.raw_notes = "A Mail.app message://<ABCDEF-GHADB-123455-FOO-BAR@example.com> link"
    todo.save!
    get :index
    assert_select("div#notes_todo_#{todo.id}", 'A Mail.app message://&lt;ABCDEF-GHADB-123455-FOO-BAR@example.com&gt; link')
    assert_select("div#notes_todo_#{todo.id} a", 'message://&lt;ABCDEF-GHADB-123455-FOO-BAR@example.com&gt;')
    assert_select("div#notes_todo_#{todo.id} a[href=message://&lt;ABCDEF-GHADB-123455-FOO-BAR@example.com&gt;]", 'message://&lt;ABCDEF-GHADB-123455-FOO-BAR@example.com&gt;')
  end

  def test_format_note_link_onenote
    login_as(:admin_user)
    todo = users(:admin_user).todos.first
    todo.notes = ' "link me to onenote":onenote:///E:\OneNote\dir\notes.one#PAGE&section-id={FD597D3A-3793-495F-8345-23D34A00DD3B}&page-id={1C95A1C7-6408-4804-B3B5-96C28426022B}&end'
    todo.save!
    get :index
    assert_select("div#notes_todo_#{todo.id}", 'link me to onenote')
    assert_select("div#notes_todo_#{todo.id} a", 'link me to onenote')
    assert_select("div#notes_todo_#{todo.id} a[href=onenote:///E:%5COneNote%5Cdir%5Cnotes.one#PAGE&amp;section-id=%7BFD597D3A-3793-495F-8345-23D34A00DD3B%7D&amp;page-id=%7B1C95A1C7-6408-4804-B3B5-96C28426022B%7D&amp;end]", 'link me to onenote')
  end

  ##############
  # dependencies
  ##############

  def test_make_todo_dependent
    login_as(:admin_user)

    predecessor = todos(:call_bill)
    successor = todos(:call_dino_ext)

    # no predecessors yet
    assert_equal 0, successor.predecessors.size

    # add predecessor
    put :add_predecessor, :predecessor=>predecessor.id, :successor=>successor.id, :format => "js"

    assert_equal 1, successor.predecessors.count
    assert_equal predecessor.id, successor.predecessors.reload.first.id
  end

  def test_make_todo_with_dependencies_dependent
    login_as(:admin_user)

    predecessor = todos(:call_bill)
    successor = todos(:call_dino_ext)
    other_todo = todos(:phone_grandfather)

    # predecessor -> successor
    put :add_predecessor, :predecessor=>predecessor.id, :successor=>successor.id, :format => "js"

    # other_todo -> predecessor -> successor
    put :add_predecessor, :predecessor=>other_todo.id, :successor=>predecessor.id, :format => "js"

    assert_equal 1, successor.predecessors(true).count
    assert_equal 0, other_todo.predecessors(true).count
    assert_equal 1, predecessor.predecessors(true).count
    assert_equal predecessor.id, successor.predecessors.first.id
    assert_equal other_todo.id, predecessor.predecessors.first.id
  end

  def test_mingle_dependent_todos_leave
    # based on #1271
    login_as(:admin_user)

    t1 = todos(:call_bill)
    t2 = todos(:call_dino_ext)
    t3 = todos(:phone_grandfather)
    t4 = todos(:construct_dilation_device)

    # t1 -> t2
    put :add_predecessor, :predecessor=>t1.id, :successor=>t2.id, :format => "js"
    # t3 -> t4
    put :add_predecessor, :predecessor=>t3.id, :successor=>t4.id, :format => "js"

    # t2 -> t4
    put :add_predecessor, :predecessor=>t2.id, :successor=>t4.id, :format => "js"

    # should be: t1 -> t2 -> t4 and t3 -> t4
    assert t4.predecessors.map(&:id).include?(t2.id)
    assert t4.predecessors.map(&:id).include?(t3.id)
    assert t2.predecessors.map(&:id).include?(t1.id)
  end

  def test_mingle_dependent_todos_root
    # based on #1271
    login_as(:admin_user)

    t1 = todos(:call_bill)
    t2 = todos(:call_dino_ext)
    t3 = todos(:phone_grandfather)
    t4 = todos(:construct_dilation_device)

    # t1 -> t2
    put :add_predecessor, :predecessor=>t1.id, :successor=>t2.id, :format => "js"
    # t3 -> t4
    put :add_predecessor, :predecessor=>t3.id, :successor=>t4.id, :format => "js"

    # t3 -> t2
    put :add_predecessor, :predecessor=>t3.id, :successor=>t2.id, :format => "js"

    # should be: t1 -> t2 and t3 -> t4 & t2
    assert t3.successors.map(&:id).include?(t4.id)
    assert t3.successors.map(&:id).include?(t2.id)
    assert t2.predecessors.map(&:id).include?(t1.id)
    assert t2.predecessors.map(&:id).include?(t3.id)
  end

  def test_unmingle_dependent_todos
    # based on #1271
    login_as(:admin_user)

    t1 = todos(:call_bill)
    t2 = todos(:call_dino_ext)
    t3 = todos(:phone_grandfather)
    t4 = todos(:construct_dilation_device)

    # create same dependency tree as previous test
    # should be: t1 -> t2 -> t4 and t3 -> t4
    put :add_predecessor, :predecessor=>t1.id, :successor=>t2.id, :format => "js"
    put :add_predecessor, :predecessor=>t3.id, :successor=>t4.id, :format => "js"
    put :add_predecessor, :predecessor=>t2.id, :successor=>t4.id, :format => "js"

    # removing t4 as successor of t2 should leave t4 blocked with t3 as predecessor
    put :remove_predecessor, :predecessor=>t2.id, :id=>t4.id, :format => "js"

    t4.reload
    assert t4.pending?, "t4 should remain pending"
    assert t4.predecessors.map(&:id).include?(t3.id)
  end


  def test_do_not_activate_done_successors
    login_as(:admin_user)
    predecessor = Todo.find(1)
    successor = Todo.find(2)
    successor.add_predecessor(predecessor)

    successor.complete!
    xhr :post, :toggle_check, :id => predecessor.id, :_source_view => 'todo'

    predecessor.reload
    successor.reload
    assert !predecessor.active?
    assert !successor.active?
    assert predecessor.completed?
    assert successor.completed?
  end

  private

  def create_todo(params={})
    defaults = { source_view: 'todo',
      context_name: "library", project_name: "Build a working time machine",
      notes: "note", description: "a new todo", due: nil, tag_list: "a,b,c"}

    params=params.reverse_merge(defaults)

    put :create, _source_view: params[:_source_view],
      context_name: params[:context_name], project_name: params[:project_name], tag_list: params[:tag_list],
      todo: {notes: params[:notes], description: params[:description], due: params[:due], show_from: params[:show_from]}
  end

end
