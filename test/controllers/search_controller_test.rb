require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  
  def setup
  end

  def test_get_search_page
    login_as :admin_user
    get :index
    assert_response 200
  end
  
  def test_search_for_todo_with_tag
    login_as :admin_user
    post :results, :search => "gates"
    assert_response 200
    assert_equal 3, assigns['count'], "should have found 3 todos"
  end
  
end
