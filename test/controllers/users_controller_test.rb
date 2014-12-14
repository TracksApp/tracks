require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to login_path
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
    assert_equal 4, assigns['total_users']
    assert_equal users_url, session['return-to']
  end

  def test_index_pagination_page_1
    User.per_page = 1
    login_as :admin_user
    get :index
    assert_equal assigns['users'],[User.where(:login => 'admin').first]
  end

  def test_index_pagination_page_2
    User.per_page = 1
    login_as :admin_user
    get :index, :page => 2
    assert_equal assigns['users'],[User.where(:login => 'jane').first]
  end

  def test_destroy_user
    login_as :admin_user
    @no_users_before = User.count
    user_id = users(:ldap_user).id
    xhr :post, :destroy, :id => user_id.to_param
    assert_equal @no_users_before-1, User.count
  end

  def test_update_password_successful
    get :change_password, :id => users(:admin_user).id 
    # should fail because no login
    assert_redirected_to login_path
    login_as :admin_user
    @user = @request.session['user_id']
    get :change_password, :id => users(:admin_user).id # should now pass because we're logged in
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Change password"
    post :update_password, :id => users(:admin_user).id, :user => {:password => 'newpassword', :password_confirmation => 'newpassword'}
    assert_redirected_to preferences_path
    @updated_user = User.find(users(:admin_user).id)
    assert_not_nil User.authenticate(@updated_user.login, 'newpassword')
    assert_equal "Password updated.", flash[:notice]
  end

  def test_update_password_no_confirmation
    post :update_password, :id => users(:admin_user).id, :user => {:password => 'newpassword', :password_confirmation => 'wrong'} 
    # should fail because no login
    assert_redirected_to login_path
    login_as :admin_user
    post :update_password, :id => users(:admin_user).id, :user => {:password => 'newpassword', :password_confirmation => 'wrong'}
    assert_redirected_to change_password_user_path(users(:admin_user))
    assert_equal 'Validation failed: Password confirmation doesn\'t match confirmation', flash[:error]
  end

  def test_update_password_validation_errors
    post :update_password, :id => users(:admin_user).id
    # should fail because no login
    assert_redirected_to login_path
    login_as :admin_user
    post :update_password, :id => users(:admin_user).id, :user => {:password => 'ba', :password_confirmation => 'ba'}
    assert_redirected_to change_password_user_path(User.find(users(:admin_user).id))
    # For some reason, no errors are being raised now.
    #assert_equal 1, users(:admin_user).errors.count
    #assert_equal users(:admin_user).errors.on(:password), "is too short (min is 5 characters)"
    assert_equal 'Validation failed: Password is too short (minimum is 5 characters)', flash[:error]
  end

  # ============================================
  # Signup and creation of new users
  # ============================================

  def test_with_no_users
    User.expects(:no_users_yet?).returns(true)
    get :new
    assert_match /get started/, assigns['heading']
    assert_not_nil assigns[:user]
  end

  def test_create_adds_a_new_nonadmin_user
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    newbie = User.where(:login => 'newbie').first
    assert_equal newbie.login, "newbie"
    assert newbie.is_admin == false || newbie.is_admin == 0
    assert_not_nil newbie.preference # have user preferences been created?
    assert_not_nil User.authenticate('newbie', 'newbiepass')
  end

  def test_create_redirects_to_home_page
    login_as :admin_user
    post :create, :user => {:login => 'newbie', :password => 'newbiepass', :password_confirmation => 'newbiepass'}
    assert_redirected_to root_url
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
