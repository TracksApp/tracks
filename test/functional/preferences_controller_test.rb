require File.dirname(__FILE__) + '/../test_helper'
require 'preferences_controller'
require 'preference'

# Re-raise errors caught by the controller.
class PreferencesController; def rescue_action(e) raise e end; end

class PreferencesControllerTest < ActionController::TestCase
  fixtures :users, :preferences
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @controller = PreferencesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_preferences
    get :index # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as :admin_user
    get :index
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Preferences"
    assert_not_nil assigns['prefs']
  end
  
  def test_edit_preferences
    get :edit # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
    login_as :admin_user
    get :edit
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Edit Preferences"
    assert_template 'preferences/edit'
  end
  
  def test_update_preferences
    login_as :admin_user
    post :update, {:user => { :first_name => 'Jane', :last_name => 'Doe'}, :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1", :admin_email => "my.email@domain.com" }}
    updated_admin_user = users(:admin_user).reload
    assert_not_nil updated_admin_user.preference
    assert_equal 'Jane', updated_admin_user.first_name
    assert_equal 'Doe', updated_admin_user.last_name
    assert_redirected_to :action => 'index'
  end
  
end
