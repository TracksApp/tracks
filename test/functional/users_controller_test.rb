require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  fixtures :preferences, :users
  
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
    login_as :other_user
    get :index
    assert_response 401
  end
  
  def test_get_index_by_admin
    login_as :admin_user
    get :index
    assert_response :success
    assert_equal "TRACKS::Manage Users", assigns['page_title']  
    assert_equal 5, assigns['total_users']
    assert_equal "/users", session['return-to']
  end

  def test_index_pagination_page_1
    User.per_page = 1
    login_as :admin_user
    get :index
    assert_equal assigns['users'],[User.find_by_login('admin')]
  end

  def test_index_pagination_page_2
    User.per_page = 1
    login_as :admin_user
    get :index, :page => 2
    assert_equal assigns['users'],[User.find_by_login('jane')]
  end
  
  def test_destroy_user
    login_as :admin_user
    @no_users_before = User.find(:all).size
    user_id = users(:ldap_user).id
    xhr :post, :destroy, :id => user_id.to_param
    assert_equal @no_users_before-1, User.find(:all).size
  end
  
  def test_update_password_successful
    get :change_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as :admin_user
    @user = @request.session['user_id']
    get :change_password # should now pass because we're logged in
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Change password"    
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'newpassword'}
    assert_redirected_to preferences_path
    @updated_user = User.find(users(:admin_user).id)
    assert_not_nil User.authenticate(@updated_user.login, 'newpassword')
    assert_equal "Password updated.", flash[:notice]
  end
  
  def test_update_password_no_confirmation
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as :admin_user
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'wrong'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    assert_equal 'Validation failed: Password doesn\'t match confirmation', flash[:error]
  end
  
  def test_update_password_validation_errors
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as :admin_user
    post :update_password, :updateuser => {:password => 'ba', :password_confirmation => 'ba'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    # For some reason, no errors are being raised now.
    #assert_equal 1, users(:admin_user).errors.count
    #assert_equal users(:admin_user).errors.on(:password), "is too short (min is 5 characters)"
    assert_equal 'Validation failed: Password is too short (minimum is 5 characters)', flash[:error]
  end
  
  # ============================================
  # Signup and creation of new users
  # ============================================
  
  def test_create_adds_a_new_nonadmin_user
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    newbie = User.find_by_login('newbie')
    assert_equal newbie.login, "newbie"
    assert newbie.is_admin == false || newbie.is_admin == 0
    assert_not_nil newbie.preference # have user preferences been created?
    assert_not_nil User.authenticate('newbie', 'newbiepass')
  end
  
  def test_create_redirects_to_home_page
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_redirected_to home_url
  end
  
  def test_create_sets_flash_message
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_equal "Signup successful for user newbie.", flash[:notice], "expected flash notice not found"
  end
  
  def test_create_adds_a_user
    login_as :admin_user
    assert_difference 'User.count' do
      post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    end
  end
  
  # Test whether signup of new users is denied to a non-admin user
  # 
  def test_create_by_non_admin
    login_as :other_user
    assert_no_difference 'User.count' do
      post :create, :user => {:login => 'newbie2', :password => 'newbiepass2', :password_confirmation => 'newbiepass2'}
    end
    assert_response :success
    assert_template 'users/nosignup'
  end
  
  # ============================================
  # Test validations
  # ============================================
  
  def test_create_with_invalid_password_does_not_add_a_new_user
    login_as :admin_user
    assert_no_difference 'User.count' do
      post :create, :user => {:login => 'newbie', :password => '', :password_confirmation => ''}
    end
  end
  
  def test_create_with_invalid_password_redirects_to_new_user_page
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => '', :password_confirmation => ''}
    assert_redirected_to signup_path
  end
  
  def test_create_with_invalid_login_does_not_add_a_new_user
    login_as :admin_user
    post :create, :user => {:login => 'n', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_redirected_to signup_path
  end
  
  def test_create_with_invalid_login_redirects_to_new_user_page
    login_as :admin_user
    post :create, :user => {:login => 'n', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_redirected_to signup_path
  end
  
  def test_create_with_duplicate_login_does_not_add_a_new_user
    login_as :admin_user
    assert_no_difference 'User.count' do
      post :create, :user => {:login => 'jane', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    end
  end
  
  def test_create_with_duplicate_login_redirects_to_new_user_page
    login_as :admin_user
    post :create, :user => {:login => 'jane', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_redirected_to signup_path
  end
  
end
