require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RecurringTodosControllerTest < ActionController::TestCase

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to login_path
  end

  def test_destroy_recurring_todo
    login_as(:admin_user)
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    begin
      rc = RecurringTodo.find(1)
    rescue
      rc = nil
    end
    assert_nil rc
  end

  def test_new_recurring_todo
    login_as(:admin_user)
    orig_rt_count = RecurringTodo.count
    orig_todo_count = Todo.count
    put :create,
      "context_name"=>"library",
      "project_name"=>"Build a working time machine",
      "recurring_todo" =>
      {
      "daily_every_x_days"=>"1",
      "daily_selector"=>"daily_every_x_day",
      "description"=>"new recurring pattern",
      "end_date" => "31/08/2010",
      "ends_on" => "ends_on_end_date",
      "monthly_day_of_week" => "1",
      "monthly_every_x_day" => "18",
      "monthly_every_x_month2" => "1",
      "monthly_every_x_month" => "1",
      "monthly_every_xth_day"=>"1",
      "monthly_selector"=>"monthly_every_x_day",
      "notes"=>"with some notes",
      "number_of_occurences" => "",
      "recurring_period"=>"yearly",
      "recurring_show_days_before"=>"10",
      "recurring_target"=>"due_date",
      "recurring_show_always" => "1",
      "start_from"=>"18/08/2008",
      "weekly_every_x_week"=>"1",
      "weekly_return_monday"=>"m",
      "yearly_day_of_week"=>"1",
      "yearly_every_x_day"=>"8",
      "yearly_every_xth_day"=>"1",
      "yearly_month_of_year2"=>"8",
      "yearly_month_of_year"=>"6",
      "yearly_selector"=>"yearly_every_x_day"
    },
      "tag_list"=>"one, two, three, four", :format => :js

    # check new recurring todo added
    assert_equal orig_rt_count+1, RecurringTodo.count
    # check new todo added
    assert_equal orig_todo_count+1, Todo.count
  end

  def test_new_recurring_todo_handles_attribs_outside_rec_todo
    login_as(:admin_user)

    # check new rec todo is not there
    assert_nil RecurringTodo.where(:description => "new recurring pattern").first

    put :create,
      "context_name"=>"library",
      "project_name"=>"Build a working time machine",
      "recurring_todo" =>
      {
      "daily_every_x_days"=>"1",
      "daily_selector"=>"daily_every_x_day",
      "description"=>"new recurring pattern",
      "end_date" => "31/08/2010",
      "ends_on" => "ends_on_end_date",
      "monthly_day_of_week" => "1",
      "monthly_every_x_day" => "18",
      "monthly_every_x_month2" => "1",
      "monthly_every_x_month" => "1",
      "monthly_every_xth_day"=>"1",
      "monthly_selector"=>"monthly_every_x_day",
      "notes"=>"with some notes",
      "number_of_occurences" => "",
      "recurring_period"=>"yearly",
      "recurring_show_days_before"=>"10",
      "recurring_target"=>"due_date",
      "recurring_show_always" => "1",
      "start_from"=>"18/08/2008",
      "weekly_every_x_week"=>"1",
      "weekly_return_monday"=>"m",
      "yearly_day_of_week"=>"1",
      "yearly_every_x_day"=>"8",
      "yearly_every_xth_day"=>"1",
      "yearly_month_of_year2"=>"8",
      "yearly_month_of_year"=>"6",
      "yearly_selector"=>"yearly_every_x_day"
    },
      "tag_list"=>"one, two, three, four", :format => :js

    new_rec_todo = RecurringTodo.where(:description => "new recurring pattern").first

    assert_not_nil new_rec_todo

  end

  def test_recurring_todo_toggle_check
    # the test fixtures did add recurring_todos but not the corresponding todos,
    # so we check complete and uncheck to force creation of a todo from the
    # pattern
    login_as(:admin_user)

    # mark as complete
    xhr :post, :toggle_check, :id=>1, :_source_view=>""
    recurring_todo_1 = RecurringTodo.find(1)
    assert recurring_todo_1.completed?

    # remove remaining todo
    todo = Todo.where(:recurring_todo_id => 1).first
    todo.recurring_todo_id = 2
    todo.save

    todo_count = Todo.count

    # mark as active
    xhr :post, :toggle_check, :id=>1, :_source_view=>""
    
    recurring_todo_1 = RecurringTodo.find(1) # reload seems to not work
    assert recurring_todo_1.active?, "recurring todo should be active but is #{recurring_todo_1.aasm.current_state}"

    # by making  active, a new todo should be created from the pattern
    assert_equal todo_count+1, Todo.count

    # find the new todo and check its description
    new_todo = Todo.where(:recurring_todo_id => 1).first
    assert_equal "Call Bill Gates every day", new_todo.description
  end

  def test_creating_recurring_todo_with_show_from_in_past
    login_as(:admin_user)

    @yearly = RecurringTodo.find(5) # yearly on june 8th

    # change due date in four days from now and show from 10 days before, i.e. 6
    # days ago
    target_date = Time.now.utc + 4.days
    @yearly.every_other1 = target_date.day
    @yearly.every_other2 = target_date.month
    @yearly.show_from_delta = 10
    #    unless @yearly.valid?
    #      @yearly.errors.each {|obj, error| puts error}
    #    end
    assert @yearly.save

    # toggle twice to force generation of new todo
    xhr :post, :toggle_check, :id=>5, :_source_view=>""
    xhr :post, :toggle_check, :id=>5, :_source_view=>""

    new_todo = Todo.where(:recurring_todo_id => 5).first

    # due date should be the target_date
    user = users(:admin_user)
    target_date = Date.new(target_date.year, target_date.month, target_date.day)
    assert_equal UserTime.new(user).midnight(target_date), new_todo.due

    # show_from should be nil since now+4.days-10.days is in the past
    assert_equal nil, new_todo.show_from
  end

  def test_last_sunday_of_march
    # this test is a duplicate of the unit test. Only this test covers the
    # codepath in the controllers

    Timecop.travel(Time.local(2012,1,1)) do

      login_as(:admin_user)

      orig_rt_count = RecurringTodo.count
      orig_todo_count = Todo.count

      put :create,
        "context_name"=>"library",
        "project_name"=>"Build a working time machine",
        "recurring_todo" =>
        {
        "daily_every_x_days"=>"1",
        "daily_selector"=>"daily_every_x_day",
        "description"=>"new recurring pattern",
        "end_date" => "",
        "ends_on" => "no_end_date",
        "monthly_day_of_week" => "1",
        "monthly_every_x_day" => "22",
        "monthly_every_x_month2" => "1",
        "monthly_every_x_month" => "1",
        "monthly_every_xth_day"=>"1",
        "monthly_selector"=>"monthly_every_x_day",
        "notes"=>"with some notes",
        "number_of_occurences" => "",
        "recurring_period"=>"yearly",
        "recurring_show_days_before"=>"0",
        "recurring_target"=>"due_date",
        "recurring_show_always" => "1",
        "start_from"=>"1/10/2012",  
        "weekly_every_x_week"=>"1",
        "weekly_return_monday"=>"w",
        "yearly_day_of_week"=>"0",
        "yearly_every_x_day"=>"22",
        "yearly_every_xth_day"=>"5",
        "yearly_month_of_year2"=>"3",
        "yearly_month_of_year"=>"10",
        "yearly_selector"=>"yearly_every_xth_day"
      },
        "tag_list"=>"one, two, three, four", :format => :js

      # check new recurring todo added
      assert_equal orig_rt_count+1, RecurringTodo.count
      # check new todo added
      assert_equal orig_todo_count+1, Todo.count

      # find the newly created todo
      new_todo = Todo.where(:description => "new recurring pattern").first
      assert !new_todo.nil?

      # the date should be 31 march 2013
      assert_equal Time.zone.local(2013,3,31), new_todo.due
    end
  end

  def test_recurring_todo_with_due_date_and_show_always
    login_as(:admin_user)

    orig_rt_count = RecurringTodo.count
    orig_todo_count = Todo.count

    put :create,
      "context_name"=>"library",
      "project_name"=>"Build a working time machine",
      "recurring_todo" =>
      {
      "daily_every_x_days"=>"1",
      "daily_selector"=>"daily_every_x_day",
      "description"=>"new recurring pattern",
      "end_date" => "",
      "ends_on" => "no_end_date",
      "monthly_day_of_week" => "1",
      "monthly_every_x_day" => "22",
      "monthly_every_x_month2" => "1",
      "monthly_every_x_month" => "1",
      "monthly_every_xth_day"=>"1",
      "monthly_selector"=>"monthly_every_x_day",
      "notes"=>"with some notes",
      "number_of_occurences" => "",
      "recurring_period"=>"yearly",
      "recurring_show_always"=>"1",
      "recurring_show_days_before"=>"0",
      "recurring_target"=>"due_date",
      "start_from"=>"1/10/2012",  # adjust after 2012
      "weekly_every_x_week"=>"1",
      "weekly_return_monday"=>"w",
      "yearly_day_of_week"=>"0",
      "yearly_every_x_day"=>"22",
      "yearly_every_xth_day"=>"5",
      "yearly_month_of_year2"=>"3",
      "yearly_month_of_year"=>"10",
      "yearly_selector"=>"yearly_every_xth_day"
    },
      "tag_list"=>"one, two, three, four", :format => :js

    # check new recurring todo added
    assert_equal orig_rt_count+1, RecurringTodo.count
    # check new todo added
    assert_equal orig_todo_count+1, Todo.count

    # find the newly created recurring todo
    recurring_todo = RecurringTodo.where(:description => "new recurring pattern").first
    assert !recurring_todo.nil?

    assert_equal "due_date", recurring_todo.target
    assert_equal true, recurring_todo.show_always?
  end

  def test_start_on_monthly_rec_todo
    Timecop.travel(Time.local(2012,1,1)) do

      login_as(:admin_user)

      put :create,
        "context_name"=>"library",
        "project_name"=>"Build a working time machine",
        "recurring_todo" =>
        {
        "daily_every_x_days"=>"1",
        "daily_selector"=>"daily_every_x_day",
        "description"=>"new recurring pattern",
        "end_date" => nil,
        "ends_on" => "no_end_date",
        "monthly_day_of_week" => "2",
        "monthly_every_x_day" => "2",
        "monthly_every_x_month2" => "1",
        "monthly_every_x_month" => "3",
        "monthly_every_xth_day"=>"1",
        "monthly_selector"=>"monthly_every_x_day",
        "notes"=>"with some notes",
        "number_of_occurences" => nil,
        "recurring_period"=>"monthly",
        "recurring_show_days_before"=>"0",
        "recurring_target"=>"show_from_date",
        "recurring_show_always" => "1",
        "start_from"=>"2/1/2013",
        "weekly_every_x_week"=>"1",
        "weekly_return_monday"=>"m",
        "yearly_day_of_week"=>"1",
        "yearly_every_x_day"=>"8",
        "yearly_every_xth_day"=>"1",
        "yearly_month_of_year2"=>"8",
        "yearly_month_of_year"=>"6",
        "yearly_selector"=>"yearly_every_x_day"
      },
        "tag_list"=>"one, two, three, four", format: :js

      assert_equal "new recurring pattern", assigns['recurring_todo'].description
      assert_equal "2013-01-02 00:00:00 +0000", assigns['recurring_todo'].start_from.to_s
      todo = assigns['recurring_todo'].todos.first
      assert_equal "2013-01-02 00:00:00 +0000", todo.show_from.to_s
    end
  end

  def test_find_and_inactivate
    login_as(:admin_user)

    rt = RecurringTodo.find(recurring_todos(:call_bill_gates_every_day).id)
    todo = Todo.where(:recurring_todo_id => rt.id).first

    assert_not_nil todo
    assert_equal "active", todo.state, "todo should be active"
    assert_equal "active", rt.state, "repeat pattern should be active"

    get :index # will call find_and_inactivate

    rt.reload
    assert_equal "active", rt.state, "repeat pattern should still be active"

    # disconnect todo from pattern thus leaving the pattern without
    # any active todos, but in active state
    todo.reload
    todo.recurring_todo_id=nil
    todo.save!

    todo.reload
    rt.reload
    assert_equal "active", rt.state, "repeat pattern should still be active and not changed"

    get :index
    rt.reload
    assert_equal "completed", rt.state, "repeat pattern should be completed"
  end

end
