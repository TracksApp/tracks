require File.dirname(__FILE__) + '/../test_helper'
require 'todo_controller'

# Re-raise errors caught by the controller.
class TodoController; def rescue_action(e) raise e end; end

class TodoControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos
  
  def setup
    @controller = TodoController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  # Test whether unlogged in users are redirected to login
  # 
  def test_get_index
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end

  def test_not_done_counts
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end

  def test_not_done_counts_after_hiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal nil, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 2, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal nil, assigns['context_not_done_counts'][contexts(:lab).id]
  end

end
