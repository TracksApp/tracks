require File.dirname(__FILE__) + '/../test_helper'
require 'mobile_controller'

# Re-raise errors caught by the controller.
class MobileController; def rescue_action(e) raise e end; end

class MobileControllerTest < Test::Unit::TestCase
  def setup
    @controller = MobileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
