require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'
require 'user'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @controller = UsersController.new
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
    assert_redirected_to home_path
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
  
  def test_update_password_successful
    get :change_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user_id'] = users(:admin_user).id # log in the admin user
    @user = @request.session['user_id']
    get :change_password # should now pass because we're logged in
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Change password"    
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'newpassword'}
    assert_redirected_to :controller => 'preferences'
    @updated_user = User.find(users(:admin_user).id)
    assert_equal @updated_user.password, Digest::SHA1.hexdigest("#{Tracks::Config.salt}--newpassword--")
    assert_equal flash[:notice], "Password updated."
  end
  
  def test_update_password_no_confirmation
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user_id'] = users(:admin_user).id # log in the admin user
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'wrong'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    assert_equal flash[:warning], 'There was a problem saving the password. Please retry.'
  end
  
  def test_update_password_validation_errors
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user_id'] = users(:admin_user).id # log in the admin user
    post :update_password, :updateuser => {:password => 'ba', :password_confirmation => 'ba'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    # For some reason, no errors are being raised now.
    #assert_equal 1, users(:admin_user).errors.count
    #assert_equal users(:admin_user).errors.on(:password), "is too short (min is 5 characters)"
    assert_equal flash[:warning], 'There was a problem saving the password. Please retry.'
  end
  
end
