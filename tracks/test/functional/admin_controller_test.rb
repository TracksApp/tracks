require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos
  
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_get_index_by_nonadmin
    @request.session['user_id'] = users(:other_user).id
    get :index
    assert_redirected_to :controller => 'todo', :action => 'index'
  end
  
  def test_get_index_by_admin
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_response :success
  end
  
  def test_destroy_user
    @no_users_before = User.find(:all).size
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :destroy, :id => 3
    assert_rjs :page, "user-3", :remove
    assert_equal @no_users_before-1, User.find(:all).size
  end
  
end
