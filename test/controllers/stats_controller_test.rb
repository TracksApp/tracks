require 'test_helper'

# TODO: Add more detailed testing of the charts. There are previously defined tests in VCS before the Flash to Chart.js change.
class StatsControllerTest < ActionController::TestCase

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to login_url
  end

  def test_get_index
    login_as(:admin_user)
    get :index
    assert_response :success
  end

  def test_totals
    login_as(:admin_user)
    get :index

    assert_response :success
    totals = assigns['stats'].totals
    assert_equal 4, totals.tags
    assert_equal 2, totals.unique_tags

    longest_running_projects = assigns['stats'].projects.runtime
    assert_equal longest_running_projects, users(:admin_user).projects.order('created_at').reverse

    Time.zone = users(:admin_user).prefs.time_zone # calculations are done in users timezone
    assert_equal 2.weeks.ago.at_midnight, totals.first_action_at.at_midnight
  end

  def test_downdrill
    login_as(:admin_user)

    # drill down without parameters
    # this will fail 500
    #
    # get :show_selected_actions_from_chart
    # assert_response :not_found
    # assert_template nil

    # get week 0-1 for actions visible running
    get :show_selected_actions_from_chart, params: { :id => 'avrt', :index => 0 }
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0 and further for actions visible running
    get :show_selected_actions_from_chart, params: { :id => 'avrt_end', :index => 0 }
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0-1 for actions running
    get :show_selected_actions_from_chart, params: { :id => 'art', :index => 0 }
    assert_response :success
    assert_template "stats/show_selection_from_chart"

    # get week 0 and further for actions running
    get :show_selected_actions_from_chart, params: { :id => 'art_end', :index => 0 }
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

  def test_show_selected_actions_from_chart_avrt
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all

    given_todos_for_stats

    # When I get the chart data
    get :show_selected_actions_from_chart, params: {:id => "avrt", :index => 1}
    assert_response :success

    assert_equal false, assigns['further']  # not at end
    assert_equal 0, assigns['count']
  end

  def test_show_selected_actions_from_chart_avrt_end
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all

    given_todos_for_stats

    # When I get the chart data
    get :show_selected_actions_from_chart, params: {:id => "avrt_end", :index => 1}
    assert_response :success

    assert assigns['further']  # at end
    assert_equal 2, assigns['count']
  end

  def test_show_selected_actions_from_chart_art
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all

    given_todos_for_stats

    # When I get the chart data
    get :show_selected_actions_from_chart, params: {:id => "art", :index => 1}
    assert_response :success

    assert_equal false, assigns['further']  # not at end
    assert_equal 0, assigns['count']
  end

  def test_show_selected_actions_from_chart_art_end
    login_as(:admin_user)
    @current_user = User.find(users(:admin_user).id)
    @current_user.todos.delete_all

    given_todos_for_stats

    # When I get the chart data
    get :show_selected_actions_from_chart, params: {:id => "art_end", :index => 1}
    assert_response :success

    assert assigns['further']  # at end
    assert_equal 2, assigns['count']
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
