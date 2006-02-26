require File.dirname(__FILE__) + '/../test_helper'
require 'todo_controller'

# Re-raise errors caught by the controller.
class TodoController; def rescue_action(e) raise e end; end

class TodoControllerTest < Test::Unit::TestCase
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

end
