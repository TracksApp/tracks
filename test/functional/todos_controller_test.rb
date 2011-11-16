require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'todos_controller'

# Re-raise errors caught by the controller.
class TodosController; def rescue_action(e) raise e end; end

class TodosControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings, :recurring_todos

  def setup
    @controller = TodosController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end

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
        "todo_tag_list"=>"1234,5667,9876"
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
        "todo_tag_list"=>"a,,b"
      # default has_many_polymorphs will fail on the empty tag
    end
    t = assigns['todo']
    assert_equal t.description, "test tags"
    assert_equal 2, t.tags.count
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

  def test_destroy_todo
    login_as(:admin_user)
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    todo = Todo.find_by_id(1)
    assert_nil todo
  end

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

  def test_fail_to_create_todo_via_xml
    login_as(:admin_user)
    # #try to create with no context, which is not valid
    put :create, :format => "xml", "request" => {
      "project_name"=>"Build a working time machine",
      "todo"=>{"notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar" }
    assert_response 422
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

  def test_update_todo_project
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_equal 1, t.project_id
  end

  def test_update_todo_project_to_none
    t = Todo.find(1)
    login_as(:admin_user)
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"None", "todo"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
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

  def test_add_multiple_todos
    login_as(:admin_user)

    start_count = Todo.count
    put :create, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "todo"=>{
      :multiple_todos=>"a\nb"}

    assert_equal start_count+2, Todo.count, "two todos should have been added"
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
      eval "@#{todo} = Todo.find_by_description('#{todo}')"
      eval "assert !@#{todo}.nil?, 'a todo with description \"#{todo}\" should just have been added'"
    end

    assert @b.predecessors.include?(@a), "a should be a predeccesor of b"
    assert !@d.predecessors.include?(@c), "c should not be a predecessor of d"
  end

  def test_find_tagged_with
    login_as(:admin_user)
    @user = User.find(@request.session['user_id'])
    tag = Tag.find_by_name('foo').todos
    @tagged = tag.count
    get :tag, :name => 'foo'
    assert_response :success
    assert_equal 3, @tagged
  end

  def test_rss_feed
    login_as(:admin_user)
    get :index, { :format => "rss" }
    assert_equal 'application/rss+xml', @response.content_type
    # puts @response.body

    assert_xml_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Actions'
        assert_select '>description', "Actions for #{users(:admin_user).display_name}"
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
        assert_select 'item', 11 do
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
        assert_select '>title', 'Actions'
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
      assert_xml_select '>title', 'Actions'
      assert_xml_select '>subtitle', "Actions for #{users(:admin_user).display_name}"
      assert_xml_select 'entry', 11 do
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

  def test_mobile_create_action_creates_a_new_todo
    login_as(:admin_user)
    post :create, {"format"=>"m", "todo"=>{"context_id"=>"2",
        "due(1i)"=>"2007", "due(2i)"=>"1", "due(3i)"=>"2",
        "show_from(1i)"=>"", "show_from(2i)"=>"", "show_from(3i)"=>"",
        "project_id"=>"1",
        "notes"=>"test notes", "description"=>"test_mobile_create_action"}}
    t = Todo.find_by_description("test_mobile_create_action")
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
        "notes"=>"test notes", "description"=>"test_mobile_create_action", "state"=>"0"}}
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

  def test_toggle_check_on_recurring_todo
    login_as(:admin_user)

    # link todo_1 and recurring_todo_1
    recurring_todo_1 = RecurringTodo.find(1)
    todo_1 = Todo.find_by_recurring_todo_id(1)

    # mark todo_1 as complete by toggle_check
    xhr :post, :toggle_check, :id => todo_1.id, :_source_view => 'todo'
    todo_1.reload
    assert todo_1.completed?

    # check that there is only one active todo belonging to recurring_todo
    count = Todo.count(:all, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'active'})
    assert_equal 1, count

    # check there is a new todo linked to the recurring pattern
    next_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'active'})
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
    count = Todo.count(:all, :conditions => {:recurring_todo_id => recurring_todo_1.id})
    assert_equal 3, count

    # check there is a new todo linked to the recurring pattern in the tickler
    next_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'deferred'})
    assert !next_todo.nil?
    assert_equal "Call Bill Gates every day", next_todo.description
    # check that the todo is in the tickler
    assert !next_todo.show_from.nil?
  end

  def test_toggle_check_on_rec_todo_show_from_today
    login_as(:admin_user)

    # link todo_1 and recurring_todo_1
    recurring_todo_1 = RecurringTodo.find(1)
    set_user_to_current_time_zone(recurring_todo_1.user)
    todo_1 = Todo.find_by_recurring_todo_id(1)
    today = Time.zone.now.at_midnight

    # change recurrence pattern to monthly and set show_from to today
    recurring_todo_1.target = 'show_from_date'
    recurring_todo_1.recurring_period = 'monthly'
    recurring_todo_1.recurrence_selector = 0
    recurring_todo_1.every_other1 = today.day
    recurring_todo_1.every_other2 = 1
    assert recurring_todo_1.save

    # mark todo_1 as complete by toggle_check, this gets rid of todo_1 that was
    # not correctly created from the adjusted recurring pattern we defined
    # above.
    xhr :post, :toggle_check, :id => todo_1.id, :_source_view => 'todo'
    todo_1.reload
    assert todo_1.completed?

    # locate the new todo. This todo is created from the adjusted recurring
    # pattern defined in this test
    new_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'active'})
    assert !new_todo.nil?

    # mark new_todo as complete by toggle_check
    xhr :post, :toggle_check, :id => new_todo.id, :_source_view => 'todo'
    new_todo.reload
    assert todo_1.completed?

    # locate the new todo in tickler
    new_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'deferred'})
    assert !new_todo.nil?

    assert_equal "Call Bill Gates every day", new_todo.description
    # check that the new todo is not the same as todo_1
    assert_not_equal todo_1.id, new_todo.id

    # check that the new_todo is in the tickler to show next month
    assert !new_todo.show_from.nil?

    # do not use today here. It somehow gets messed up with the timezone calculation.
    next_month = (Time.zone.now + 1.month).at_midnight

    assert_equal next_month.utc.to_date.to_s(:db), new_todo.show_from.utc.to_date.to_s(:db)
  end

  def test_check_for_next_todo
    login_as :admin_user

    recurring_todo_1 = RecurringTodo.find(5)
    @todo = Todo.find_by_recurring_todo_id(1)
    assert @todo.from_recurring_todo?
    # rewire @todo to yearly recurring todo
    @todo.recurring_todo_id = 5

    # make todo due tomorrow and change recurring date also to tomorrow
    @todo.due = Time.zone.now + 1.day
    @todo.save
    recurring_todo_1.every_other1 = @todo.due.day
    recurring_todo_1.every_other2 = @todo.due.month
    recurring_todo_1.save

    # mark todo complete
    xhr :post, :toggle_check, :id => @todo.id, :_source_view => 'todo'
    @todo.reload
    assert @todo.completed?

    # check that there is no active todo
    next_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'active'})
    assert next_todo.nil?

    # check for new deferred todo
    next_todo = Todo.find(:first, :conditions => {:recurring_todo_id => recurring_todo_1.id, :state => 'deferred'})
    assert !next_todo.nil?
    # check that the due date of the new todo is later than tomorrow
    assert next_todo.due > @todo.due
  end

  def test_removing_hidden_project_activates_todo
    login_as(:admin_user)

    # get a project and hide it, todos in the project should be hidden
    p = projects(:timemachine)
    p.hide!
    assert p.reload().hidden?
    todo = p.todos.first
    assert_equal "project_hidden", todo.state

    # clear project from todo: the todo should be unhidden
    xhr :post, :update, :id => 5, :_source_view => 'todo', "project_name"=>"None", "todo"=>{}
    todo.reload()
    assert_equal "active", todo.state
  end

  def test_url_with_slash_in_query_string_are_parsed_correctly
    # See http://blog.swivel.com/code/2009/06/rails-auto_link-and-certain-query-strings.html
    login_as(:admin_user)
    user = users(:admin_user)
    todo = user.todos.first
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

  def test_format_note_markdown
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
    assert_select("div#notes_todo_#{todo.id} a[href=onenote:///E:\\OneNote\\dir\\notes.one#PAGE&amp;section-id={FD597D3A-3793-495F-8345-23D34A00DD3B}&amp;page-id={1C95A1C7-6408-4804-B3B5-96C28426022B}&amp;end]", 'link me to onenote')
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

  def test_set_right_title
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

  def test_tag_text_feed_not_accessible_to_anonymous_user_without_token
    login_as nil
    get :tag, {:name => "foo", :format => "txt" }
    assert_response 401
  end

end
