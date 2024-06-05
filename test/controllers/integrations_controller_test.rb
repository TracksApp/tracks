require 'test_helper'
require 'support/stub_site_config_helper'

class IntegrationsControllerTest < ActionController::TestCase
  include StubSiteConfigHelper

  def setup
  end
  
  def test_page_load
    login_as(:admin_user)
    get :rest_api
    assert_response :success
  end
  
end
