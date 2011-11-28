require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'stats_controller'

# Re-raise errors caught by the controller.
class StatsController; def rescue_action(e) raise e end; end

class StatsControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :recurring_todos, :recurring_todos, :tags, :taggings

  def setup
    @controller = StatsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end

  def test_get_index
    login_as(:admin_user)
    get :index
    assert_response :success
  end

  def test_get_charts
    login_as(:admin_user)
    %w{    actions_done_last30days_data
	   actions_done_last12months_data
	   actions_completion_time_data
           actions_visible_running_time_data
	   actions_running_time_data
	   actions_day_of_week_all_data
	   actions_day_of_week_30days_data
	   actions_time_of_day_all_data
	   actions_time_of_day_30days_data
           context_total_actions_data
           context_running_actions_data
    }.each do |action|
      get action
      assert_response :success
      assert_template "stats/"+action
    end
  end

  def test_totals
    login_as(:admin_user)
    get :index
    assert_response :success
    assert_equal 4, assigns['tags_count']
    assert_equal 2, assigns['unique_tags_count']
    assert_equal 2.week.ago.utc.at_midnight, assigns['first_action'].created_at.utc.at_midnight
  end

  def test_downdrill
    login_as(:admin_user)

    # drill down without parameters
    get :show_selected_actions_from_chart
    assert_response :not_found
    assert_template nil

    # get week 0-1 for actions visible running
    get :show_selected_actions_from_chart, :id => 'avrt', :index => 0
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0 and further for actions visible running
    get :show_selected_actions_from_chart, :id => 'avrt_end', :index => 0
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0-1 for actions running
    get :show_selected_actions_from_chart, :id => 'art', :index => 0
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0 and further for actions running
    get :show_selected_actions_from_chart, :id => 'art_end', :index => 0
    assert_response :success
    assert_template "stats/show_selection_from_chart"
  end

  def test_stats_render_when_tasks_have_no_taggings
    login_as(:admin_user)

    # using the default fixtures, todos have tags
    get :index
    assert_response :success

    # clear taggings table and render again
    Tagging.delete_all
    get :index
    assert_response :success
  end

  def test_actions_done_last12months_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all

    given_todos_for_stats

    # When I get the chart data
    get :actions_done_last12months_data
    assert_response :success

    # Then the todos for the chart should be retrieved
    assert_not_nil assigns['actions_done_last12months']
    assert_not_nil assigns['actions_created_last12months']
    assert_equal 7, assigns['actions_created_last12months'].count, "very old todo should not be retrieved"

    # And they should be totalled in a hash
    assert_equal 2, assigns['actions_created_last12months_array'][0], "there should be two todos in current month"
    assert_equal 1, assigns['actions_created_last12months_array'][1], "there should be one todo in previous month"
    assert_equal 1, assigns['actions_created_last12months_array'][2], "there should be one todo in two month ago"
    assert_equal 1, assigns['actions_created_last12months_array'][3], "there should be one todo in three month ago"
    assert_equal 2, assigns['actions_created_last12months_array'][4], "there should be two todos (1 created & 1 done) in four month ago"

    assert_equal 1, assigns['actions_done_last12months_array'][2], "there should be one completed todo in last three months"
    assert_equal 1, assigns['actions_done_last12months_array'][4], "there should be one completed todo in last four months"

    # And they should be averaged over three months
    assert_equal 1/3.0, assigns['actions_done_avg_last12months_array'][1], "fourth month should be excluded"
    assert_equal 2/3.0, assigns['actions_done_avg_last12months_array'][2], "fourth month should be included"
    
    assert_equal 1.0,   assigns['actions_created_avg_last12months_array'][1], "one every month"
    assert_equal 4/3.0, assigns['actions_created_avg_last12months_array'][2], "two in fourth month"
    
    # And the current month should be interpolated
    fraction = Time.zone.now.day.to_f / Time.zone.now.end_of_month.day.to_f
    assert_equal (2*fraction+2)/3.0, assigns['interpolated_actions_created_this_month'], "two this month and one in the last two months"
    assert_equal 1/3.0, assigns['interpolated_actions_done_this_month'], "none this month and one in the last two months"
    
    # And totals should be calculated
    assert_equal 2, assigns['max'], "max of created or completed todos"
  end

  def test_actions_done_lastyears_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats

    # When I get the chart data
    get :actions_done_lastyears_data
    assert_response :success
    
    # only tests difference with actions_done_last_12months_data
    
    # Then the count of months should be calculated
    assert_equal 24, assigns['month_count']
    
    # And the last two months are corrected
    assert_equal 0.5, assigns['actions_done_avg_last_months_hash'][23]
    assert_equal 1.0, assigns['actions_done_avg_last_months_hash'][24]
  end
  
  def test_actions_completion_time_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats
    
    # When I get the chart data
    get :actions_completion_time_data
    assert_response :success
    
    # do not test stuff already implicitly tested in other tests
    
    assert_equal 104, assigns['max_weeks'], "two years is 104 weeks"
  end

  def test_actions_running_time_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats
    
    # When I get the chart data
    get :actions_running_time_data
    assert_response :success
    
    # do not test stuff already implicitly tested in other tests
    
    assert_equal 17, assigns['max_weeks'], "there are action in the first 17 weeks of this year"
  end

  def test_actions_visible_running_time_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats
    
    # When I get the chart data
    get :actions_visible_running_time_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats
    
    # When I get the chart data
    get :actions_running_time_data
    assert_response :success
    
    # do not test stuff already implicitly tested in other tests
    
    assert_equal 17, assigns['max_weeks'], "there are action in the first 17 weeks of this year"
  end

  private
  
  def given_todos_for_stats
    # Given two todos created today
    @todo_today1 = @current_user.todos.create!(:description => "created today1", :context => contexts(:office))
    @todo_today2 = @current_user.todos.create!(:description => "created today2", :context => contexts(:office))
    # And a todo created a month ago
    @todo_month1 = create_todo_in_past(1.month+1.day)
    # And a todo created two months ago
    @todo_month2 = create_completed_todo_in_past(2.months+1.day, 2.months+2.days)
    # And a todo created three months ago
    @todo_month3 = create_todo_in_past(3.months+1.day)
    # And a todo created four months ago
    @todo_month4 = create_todo_in_past(4.months+1.day)
    # And a todo created four months ago
    @todo_month5 = create_completed_todo_in_past(4.months+1.day, 4.months+2.days)
    # And a todo created over a year ago
    @todo_year = create_completed_todo_in_past(2.years+1.day, 2.years+2.day)
  end

  def create_todo_in_past(creation_time_in_past)
    todo = @current_user.todos.create!(:description => "created #{creation_time_in_past} ago", :context => contexts(:office))
    todo.created_at = Time.zone.now - creation_time_in_past
    todo.save!
    return todo
  end

  def create_completed_todo_in_past(creation_time_in_past, completed_time_in_past)
    todo = @current_user.todos.create!(:description => "created #{creation_time_in_past} ago", :context => contexts(:office))
    todo.complete!
    todo.completed_at = Time.zone.now - completed_time_in_past
    todo.created_at = Time.zone.now - creation_time_in_past
    todo.save!
    return todo
  end

end
