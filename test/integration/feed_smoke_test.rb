require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'
require 'contexts_controller'
require 'todos_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end
class ContextsController; def rescue_action(e) raise e end; end
class TodosController; def rescue_action(e) raise e end; end

class FeedSmokeTest < ActionController::IntegrationTest
  fixtures :users, :preferences, :projects, :contexts, :todos, :recurring_todos, :notes

  def setup
    assert_test_environment_ok
  end
  
  def test_last_15_actions_rss
    assert_success "/todos.rss?token=#{ users(:admin_user).token }&limit=15"
  end

  def test_last_15_actions_atom
    assert_success "/todos.atom?token=#{ users(:admin_user).token }&limit=15"
  end

  def test_last_15_actions_txt
    assert_success "/todos.txt?token=#{ users(:admin_user).token }&limit=15"
  end
  
  def test_last_15_actions_ical
    assert_success "/todos.ics?token=#{ users(:admin_user).token }&limit=15"
  end
  
  def test_all_actions_rss
    assert_success "/todos.rss?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_txt
    assert_success "/todos.txt?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_ical
    assert_success "/todos.ics?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_context_rss
    assert_success "/contexts/1/todos.rss?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_context_txt
    assert_success "/contexts/1/todos.txt?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_context_ical
    assert_success "/contexts/1/todos.ics?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_project_rss
    assert_success "/projects/1/todos.rss?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_project_txt
    assert_success "/projects/1/todos.txt?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_in_project_ical
    assert_success "/projects/1/todos.ics?token=#{ users(:admin_user).token }"
  end

  def test_all_actions_due_today_or_earlier_rss
    assert_success "/todos.rss?token=#{ users(:admin_user).token }&due=0"
  end
  
  def test_all_actions_due_today_or_earlier_txt
    assert_success "/todos.txt?token=#{ users(:admin_user).token }&due=0"
  end
  
  def test_all_actions_due_today_or_earlier_ical
    assert_success "/todos.ics?token=#{ users(:admin_user).token }&due=0"
  end
  
  def test_all_actions_due_in_7_days_or_earlier_rss
    assert_success "/todos.rss?token=#{ users(:admin_user).token }&due=6"
  end
  
  def test_all_actions_due_in_7_days_or_earlier_txt
    assert_success "/todos.txt?token=#{ users(:admin_user).token }&due=6"
  end
  
  def test_all_actions_due_in_7_days_or_earlier_ical
    assert_success "/todos.ics?token=#{ users(:admin_user).token }&due=6"
  end
  
  def test_all_actions_completed_in_last_7_days_rss
    assert_success "/todos.rss?token=#{ users(:admin_user).token }&done=7"
  end
  
  def test_all_actions_completed_in_last_7_days_txt
    assert_success "/todos.txt?token=#{ users(:admin_user).token }&done=7"
  end

  def test_all_contexts_rss
    assert_success "/contexts.rss?token=#{ users(:admin_user).token }"
  end

  def test_all_contexts_txt
    assert_success "/contexts.txt?token=#{ users(:admin_user).token }"
  end

  def test_all_projects_rss
    assert_success "/projects.rss?token=#{ users(:admin_user).token }"
  end

  def test_all_projects_txt
    assert_success "/projects.txt?token=#{ users(:admin_user).token }"
  end

  def test_calendar_ics
    assert_success "/calendar.ics?token=#{ users(:admin_user).token }"
  end

  def test_all_projects_txt_with_hidden_project
    p = projects(:timemachine)
    p.hide!
    assert_success "/projects.txt?token=#{ users(:admin_user).token }"
  end

  private
  
  def assert_success(url)
    get url
    assert_response :success
    #puts @response.body
  end
  
end