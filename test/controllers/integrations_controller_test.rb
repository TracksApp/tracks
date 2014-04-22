require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IntegrationsControllerTest < ActionController::TestCase

  def test_get_index_page
    login_as(:admin_user)
    get :index
    assert_response :success
  end

  def test_get_api_docs_page
    login_as(:admin_user)
    get :api_docs
    assert_response :success
  end

end
