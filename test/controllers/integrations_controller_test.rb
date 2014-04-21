require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IntegrationsControllerTest < ActionController::TestCase

  def setup
  end
  
  def test_page_load
    login_as(:admin_user)
    get :api_docs
    assert_response :success
  end
  
end
