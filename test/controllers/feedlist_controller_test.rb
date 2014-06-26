require 'test_helper'

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
  
  def test_get_feeds_for_context_using_xhr
    login_as(:admin_user)
    xhr :get, :get_feeds_for_context, :context_id => contexts(:errand).id
    assert_response 200
  end
  
  def test_get_feeds_for_project_using_xhr
    login_as(:admin_user)
    xhr :get, :get_feeds_for_project, :project_id => projects(:timemachine).id
    assert_response 200
  end
    
end