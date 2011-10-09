require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'preferences_controller'

# Re-raise errors caught by the controller.
class PreferencesController; def rescue_action(e) raise e end; end

class PreferencesControllerTest < ActionController::TestCase
  fixtures :users, :preferences

  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
  end

  test "render_date_format requires login" do
    get :render_date_format
    assert_redirected_to :controller => 'login', :action => 'login'
  end

  test "calling render_date_format returns date" do
    login_as :admin_user

    get :render_date_format
    assert_response :success
    assert_equal I18n.l(Time.zone.now, :format => "%Y-%m-%d"), @response.body

    get(:render_date_format, {:date_format => "%A %Y"})
    assert_response :success
    assert_equal I18n.l(Time.zone.now, :format => "%A %Y"), @response.body
  end

  test "index page requires login" do
    get :index # should fail because no login
    assert_redirected_to :controller => 'login', :action => 'login'
  end

  test "index sets prefs and user" do
    login_as :admin_user
    get :index
    assert_response :success
    assert_equal assigns['page_title'], "TRACKS::Preferences"
    assert_not_nil assigns['prefs']
    assert_not_nil assigns['user']
  end

  test "should update preferences" do
    login_as :admin_user
    post :update, {
      :user => { :first_name => 'Jane', :last_name => 'Doe'},
      :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1", :admin_email => "my.email@domain.com" }}
    updated_admin_user = users(:admin_user).reload
    assert_not_nil updated_admin_user.preference
    assert_equal 'Jane', updated_admin_user.first_name
    assert_equal 'Doe', updated_admin_user.last_name
    assert_redirected_to :action => 'index'
  end

  test "should not update password if left empty" do
    login_as :admin_user

    old_password_hash = users(:admin_user).password

    post :update, {
      :user => { :first_name => 'Jane', :last_name => 'Doe', :password => "", :password_confirmation => ""},
      :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1", :admin_email => "my.email@domain.com" }}

    updated_admin_user = users(:admin_user).reload
    assert_equal old_password_hash, updated_admin_user.password
  end

  test "should be able to change authentication type" do
    assert Tracks::Config.auth_schemes.include?("open_id"), "open_id should be a valid authentication scheme"

    login_as :admin_user

    post :update, {
      :user => { :first_name => 'Jane', :last_name => 'Doe', :auth_type => "open_id", :open_id_url => "http://test"},
      :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1", :admin_email => "my.email@domain.com" }}

    updated_admin_user = users(:admin_user).reload
    assert_equal "open_id", updated_admin_user.auth_type
  end

end
