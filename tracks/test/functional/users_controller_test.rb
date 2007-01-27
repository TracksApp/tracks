require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'
require 'user'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :preferences, :users
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @num_users_in_fixture = User.count
    @admin_user = users(:admin_user)
    @nonadmin_user = users(:other_user)
  end
  
  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_get_index_by_nonadmin
    login_as @nonadmin_user
    get :index
    assert_response 401
  end
  
  def test_get_index_by_admin
    login_as @admin_user
    get :index
    assert_response :success
  end
  
  def test_destroy_user
    login_as @admin_user
    @no_users_before = User.find(:all).size
    xhr :post, :destroy, :id => 3
    assert_rjs :page, "user-3", :remove
    assert_equal @no_users_before-1, User.find(:all).size
  end
  
  def test_update_password_successful
    get :change_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as @admin_user
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
    login_as @admin_user
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'wrong'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    assert_equal flash[:warning], 'There was a problem saving the password. Please retry.'
  end
  
  def test_update_password_validation_errors
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as @admin_user
    post :update_password, :updateuser => {:password => 'ba', :password_confirmation => 'ba'}
    assert_redirected_to :controller => 'users', :action => 'change_password'
    assert users(:admin_user).save, false
    # For some reason, no errors are being raised now.
    #assert_equal 1, users(:admin_user).errors.count
    #assert_equal users(:admin_user).errors.on(:password), "is too short (min is 5 characters)"
    assert_equal flash[:warning], 'There was a problem saving the password. Please retry.'
  end
  
  # ============================================
  # Signup and creation of new users
  # ============================================
  
  def test_create
    login_as @admin_user
    newbie = create('newbie', 'newbiepass')
    assert_equal "Signup successful for user newbie.", flash[:notice], "expected flash notice not found"
    assert_redirected_to home_url
    assert_valid newbie
    session['user_id'] = nil # logout the admin user
    assert_equal newbie.login, "newbie"
    assert newbie.is_admin == false || newbie.is_admin == 0
    assert_not_nil newbie.preference # have user preferences been created?
    assert_not_nil User.authenticate('newbie', 'newbiepass')
    assert_equal User.count, @num_users_in_fixture + 1
  end
  
  # Test whether signup of new users is denied to a non-admin user
  # 
  def test_create_by_non_admin
    non_admin = login_as @nonadmin_user
    post :create, :user => {:login => 'newbie2', :password => 'newbiepass2', :password_confirmation => 'newbiepass2'}
    assert_response :success
    assert_template 'users/nosignup'
    assert_number_of_users_is_unchanged
  end
  
  # ============================================
  # Test validations
  # ============================================
  
  def test_create_with_invalid_password
    login_as @admin_user
    post :create, :user => {:login => 'newbie', :password => '', :password_confirmation => ''}
    assert_number_of_users_is_unchanged
    assert_redirected_to :controller => 'users', :action => 'new'    
  end
  
  def test_create_with_invalid_user
    login_as @admin_user
    post :create, :user => {:login => 'n', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_number_of_users_is_unchanged
    assert_redirected_to :controller => 'users', :action => 'new'    
  end
  
  # Test uniqueness of login
  #
  def test_validate_uniqueness_of_login
    login_as @admin_user
    post :create, :user => {:login => 'jane', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    num_users = User.find(:all)
    assert_number_of_users_is_unchanged
    assert_redirected_to :controller => 'users', :action => 'new'    
  end
  
  private
  
  def login_as(user)
    returning user do |u|
      @request.session['user_id'] = u.id
    end
  end
  
  # Creates a new users with the login and password given
  def create(login,password)
    post :create, :user => {:login => login, :password => password, :password_confirmation => password}
    return User.find_by_login(login)
  end
  
  def assert_number_of_users_is_unchanged
    assert_equal User.count, @num_users_in_fixture    
  end
  
  
end
