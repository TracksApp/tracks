require File.dirname(__FILE__) + '/../test_helper'
require 'context_controller'

# Re-raise errors caught by the controller.
class ContextController; def rescue_action(e) raise e end; end

class ContextControllerTest < Test::Unit::TestCase
  def setup
    @controller = ContextController.new
    request, response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
