require File.dirname(__FILE__) + '/../test_helper'
require 'integrations_controller'

# Re-raise errors caught by the controller.
class IntegrationsController; def rescue_action(e) raise e end; end

class IntegrationsControllerTest < Test::Unit::TestCase
  def setup
    @controller = IntegrationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
