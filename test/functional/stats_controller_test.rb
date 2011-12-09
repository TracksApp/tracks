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
    %w{
      actions_done_last30days_data
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

    # these test use relative dates. It will go wrong when the data is [1-8] of the month :-(
    # FIXME: make testdata not relative of today to avoid crossing end_of_month
    too_early = Time.zone.now.day <= 8 ? 1 : 0

    assert_equal 1-too_early, assigns['actions_created_last12months_array'][1], "there should be one todo in previous month"
    assert_equal 1+too_early, assigns['actions_created_last12months_array'][2], "there should be one todo in two month ago"
    assert_equal 1, assigns['actions_created_last12months_array'][3], "there should be one todo in three month ago"
    assert_equal 2, assigns['actions_created_last12months_array'][4], "there should be two todos (1 created & 1 done) in four month ago"

    assert_equal 1, assigns['actions_done_last12months_array'][1], "there should be one completed todo one-two months ago"
    assert_equal 1, assigns['actions_done_last12months_array'][2], "there should be one completed todo two-three months ago"
    assert_equal 1, assigns['actions_done_last12months_array'][4], "there should be one completed todo four-five months ago"

    # And they should be averaged over three months
    assert_equal 2/3.0, assigns['actions_done_avg_last12months_array'][1], "fourth month should be excluded"
    assert_equal 2/3.0, assigns['actions_done_avg_last12months_array'][2], "fourth month should be included"
    
    assert_equal 3/3.0, assigns['actions_created_avg_last12months_array'][1], "one every month"
    assert_equal (4+too_early)/3.0, assigns['actions_created_avg_last12months_array'][2], "two in fourth month"
    
    # And the current month should be interpolated
    fraction = Time.zone.now.day.to_f / Time.zone.now.end_of_month.day.to_f
    assert_equal (2*fraction+2)/3.0, assigns['interpolated_actions_created_this_month'], "two this month and one in the last two months"
    assert_equal 2/3.0, assigns['interpolated_actions_done_this_month'], "none this month and one two the last two months"
    
    # And totals should be calculated
    assert_equal 2, assigns['max'], "max of created or completed todos in one month"
  end

  def test_actions_done_last30days_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats

    # When I get the chart data
    get :actions_done_last30days_data
    assert_response :success

    # only tests relevant differences with actions_done_last_12months_data
    
    assert_equal 31, assigns['actions_done_last30days_array'].size, "30 complete days plus 1 for the current day"
    assert_equal 2, assigns['max'], "two actions created on one day is max"
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
    assert_equal 27, assigns['month_count'], "two years and three months of last todo"
    
    # And the last two months are corrected
    assert_equal 2/3.0, assigns['actions_done_avg_last_months_array'][23]
    assert_equal 2/3.0, assigns['actions_done_avg_last_months_array'][24]
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
    assert_equal 104,   assigns['max_weeks'], "two years is 104 weeks (for completed_at)"
    assert_equal   3,   assigns['max_actions'], "3 completed within one week"
    assert_equal  11,   assigns['actions_completion_time_array'].size, "there should be 10 weeks of data + 1 for the rest"
    assert_equal   1,   assigns['actions_completion_time_array'][10], "there is one completed todo after the 10 weeks cut_off"
    assert_equal 100.0, assigns['cumm_percent_done'][10], "cummulative percentage should add up to 100%"
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
    assert_equal  17,   assigns['max_weeks'], "there are actions in the first 17 weeks of this year"
    assert_equal   2,   assigns['max_actions'], "2 actions running long together"
    assert_equal  18,   assigns['actions_running_time_array'].size, "there should be 17 weeks ( < cut_off) of data + 1 for the rest"
    assert_equal   1,   assigns['actions_running_time_array'][17], "there is one running todos in week 17 and zero after 17 weeks ( < cut off; ) "
    assert_equal 100.0, assigns['cumm_percent_done'][17], "cummulative percentage should add up to 100%"
  end

  def test_actions_visible_running_time_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats
    # Given todo1 is deferred (i.e. not visible)
    @todo_today1.show_from = Time.zone.now + 1.week
    @todo_today1.save
    
    # When I get the chart data
    get :actions_visible_running_time_data
    assert_response :success

    # do not test stuff already implicitly tested in other tests
    assert_equal  17,   assigns['max_weeks'], "there are actions in the first 17 weeks of this year"
    assert_equal   1,   assigns['max_actions'], "1 action running long; 1 is deferred"
    assert_equal   1,   assigns['actions_running_time_array'][0], "there is one running todos and one deferred todo created in week 1"
    assert_equal  18,   assigns['actions_running_time_array'].size, "there should be 17 weeks ( < cut_off) of data + 1 for the rest"
    assert_equal   1,   assigns['actions_running_time_array'][17], "there is one running todos in week 17 and zero after 17 weeks ( < cut off; ) "
    assert_equal 100.0, assigns['cumm_percent_done'][17], "cummulative percentage should add up to 100%"
  end

  def test_context_total_actions_data
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all
    
    given_todos_for_stats

    # When I get the chart data
    get :context_total_actions_data
    assert_response :success

    assert_equal 9, assigns['sum'], "Nine todos in 1 context"
    assert_equal 1, assigns['actions_per_context'].size

    # Given 10 more todos in 10 different contexts
    1.upto(10) do |i|
      context = @current_user.contexts.create!(:name => "context #{i}")
      @current_user.todos.create!(:description => "created today with new context #{i}", :context => context)
    end

    # When I get the chart data
    get :context_total_actions_data
    assert_response :success

    assert_equal 19, assigns['sum'], "added 10 todos"
    assert_equal 10, assigns['actions_per_context'].size, "pie slices limited to max 10"
    assert_equal  2, assigns['actions_per_context'][9]['total'], "pie slices limited to max 10; last pie contains sum of rest"
    assert_equal "(others)",  assigns['actions_per_context'][9]['name'], "pie slices limited to max 10; last slice contains label for others"
  end

  private
  
  def given_todos_for_stats
    # Given two todos created today
    @todo_today1 = @current_user.todos.create!(:description => "created today1", :context => contexts(:office))
    @todo_today2 = @current_user.todos.create!(:description => "created today2", :context => contexts(:office))
    # And a todo created a month ago
    @todo_month1 = create_completed_todo_in_past(1.month+1.weeks+1.day, 1.month+1.day)
    # And a todo created two months ago
    @todo_month2 = create_completed_todo_in_past(2.months+2.days, 2.months+1.day)
    # And a todo created three months ago
    @todo_month3 = create_todo_in_past(3.months+1.day)
    # And a todo created four months ago
    @todo_month4 = create_todo_in_past(4.months+1.day)
    # And a todo created four months ago
    @todo_month5 = create_completed_todo_in_past(4.months+2.days, 4.months+1.day)
    # And a todo created over a year ago
    @todo_year1 = create_completed_todo_in_past(2.years+2.days, 2.years+1.day)
    @todo_year2 = create_completed_todo_in_past(2.years+3.months, 2.years+1.day)
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

  # assumes date1 > date2
  def difference_in_days(date1, date2)
    return ((date1.at_midnight-date2.at_midnight)/(60*60*24)).to_i
  end
  
  # assumes date1 > date2
  def difference_in_weeks(date1, date2)
    return difference_in_days(date1, date2) / 7
  end

  # assumes date1 > date2
  def difference_in_months(date1, date2)
    diff = (date1.year - date2.year)*12 + (date1.month - date2.month)
    return diff-1 if date1.day - date2.day < 0 # correct for incomplete months
    return diff
  end

end
