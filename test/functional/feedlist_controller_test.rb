require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class FeedlistControllerTest < ActionController::TestCase
  
  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to login_path
  end
  
  def test_get_index_by_logged_in_user
    login_as :other_user
    get :index
    assert_response :success
    assert_equal "TRACKS::Feeds", assigns['page_title']
  end
    
end