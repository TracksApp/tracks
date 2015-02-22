require 'test_helper'

class PreferencesControllerTest < ActionController::TestCase

  test "render_date_format requires login" do
    get :render_date_format
    assert_redirected_to login_path
  end

  test "calling render_date_format returns date" do
    login_as :admin_user

    get :render_date_format
    assert_response :success
    assert_equal I18n.l(Date.current, :format => "%Y-%m-%d"), @response.body

    get(:render_date_format, {:date_format => "%A %Y"})
    assert_response :success
    assert_equal I18n.l(Date.current, :format => "%A %Y"), @response.body
  end

  test "index page requires login" do
    get :index # should fail because no login
    assert_redirected_to login_path
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
      :id => users(:admin_user).id,
      :user => { :first_name => 'Jane', :last_name => 'Doe'},
      :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1" }}
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
      :id => users(:admin_user).id,
      :user => { :first_name => 'Jane', :last_name => 'Doe', :password => "", :password_confirmation => ""},
      :prefs => { :date_format => "%m-%d-%Y", :week_starts => "0", :show_number_completed => "10", :show_completed_projects_in_sidebar => "false", :show_hidden_contexts_in_sidebar => "false", :staleness_starts => "14", :due_style => "1" }}

    updated_admin_user = users(:admin_user).reload
    assert_equal old_password_hash, updated_admin_user.password
  end

end
