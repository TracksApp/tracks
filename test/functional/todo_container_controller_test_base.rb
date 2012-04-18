class TodoContainerControllerTestBase < ActionController::TestCase

  def setup_controller_request_and_response
    # ## override with empty
    # TODO: remove these ugly hacks
  end

  def perform_setup(container_class, controller_class)
    @controller = controller_class.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    login_as :other_user
    @initial_count = container_class.count
    @container_class = container_class
  end
  
  def test_truth
    assert true
  end
  
  
end
