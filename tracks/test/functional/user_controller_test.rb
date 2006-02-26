require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'
require 'user'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", SALT
    @admin_user = User.find(1)
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Test index with and without login
  # 
  def test_index
    get :index # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    get :index
    assert_success
  end
  
  # Test admin with and without login
  # 
  def test_admin
    get :admin # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    get :admin
    assert_success
  end
  
  def test_preferences
    get :preferences # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    get :preferences
    assert_success
    assert_equal assigns['page_title'], "TRACKS::Preferences"
    assert_not_nil assigns['prefs']
    assert_equal assigns['prefs'].length, 6
  end
  
  def test_edit_preferences
    get :edit_preferences # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    get :edit_preferences
    assert_success
    assert_equal assigns['page_title'], "TRACKS::Edit Preferences"
    assert_not_nil assigns['prefs']
    assert_equal assigns['prefs'].length, 6    
    assert_template 'user/preference_edit_form'
  end
  
  # Test updating of preferences
  # FIXME seems to be difficult to test serialization of preferences using YAML
  #
  def test_update_preferences
    @request.session['user'] = @admin_user # log in the admin user
    @admin_user.preferences = post :update_preferences, :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :no_completed => "10", :staleness_starts => "14", :due_style => "1", :admin_email => "my.email@domain.com" }
    @prefs = @admin_user.preferences
    assert_not_nil @prefs
    assert_redirected_to :action => 'preferences'
  end

  def test_change_password
    get :change_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    get :change_password
    assert_success
    assert_equal assigns['page_title'], "TRACKS::Change password"
    assert_not_nil assigns['user']
    assert_equal assigns['user'], @admin_user
  end
  
  def test_update_password_successful
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'newpassword'}
    assert_redirected_to :controller => 'user', :action => 'preferences'
    assert_equal @admin_user.password, Digest::SHA1.hexdigest("#{SALT}--newpassword--")
    assert_equal flash['notice'], "Password updated."
  end
  
  def test_update_password_no_confirmation
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    post :update_password, :updateuser => {:password => 'newpassword', :password_confirmation => 'wrong'}
    assert_redirected_to :controller => 'user', :action => 'change_password'
    assert !@admin_user.save
    assert_equal flash['warning'], 'There was a problem saving the password. Please retry.'
  end
  
  def test_update_password_validation_errors
    post :update_password # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    @request.session['user'] = @admin_user # log in the admin user
    post :update_password, :updateuser => {:password => 'ba', :password_confirmation => 'ba'}
    assert_redirected_to :controller => 'user', :action => 'change_password'
    assert !@admin_user.save
    assert_equal 1, @admin_user.errors.count
    assert_equal @admin_user.errors.on(:password), "is too short (min is 5 characters)"
    assert_equal flash['warning'], 'There was a problem saving the password. Please retry.'
  end
  
end
