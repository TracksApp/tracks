require File.dirname(__FILE__) + '/../test_helper'
require 'feedlist_controller'

# Re-raise errors caught by the controller.
class FeedlistController; def rescue_action(e) raise e end; end

class FeedlistControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :recurring_todos, :notes
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
    @controller = FeedlistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_get_index_by_logged_in_user
    login_as :other_user
    get :index
    assert_response :success
    assert_equal "TRACKS::Feeds", assigns['page_title']  
  end
    
end
