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
    assert_equal 3, assigns['projects'].count
    assert_equal 3, assigns['projects'].count(:conditions => "state = 'active'")
    assert_equal 10, assigns['contexts'].count
    assert_equal 17, assigns['actions'].count
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
end
