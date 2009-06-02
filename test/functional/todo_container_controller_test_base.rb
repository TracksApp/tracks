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
  
  def assert_ajax_create_increments_count(name)
    assert_count_after_ajax_create(name, @initial_count + 1)
  end
  
  def assert_ajax_create_does_not_increment_count(name)
    assert_count_after_ajax_create(name, @initial_count)
  end
  
  def assert_count_after_ajax_create(name, expected_count)
    ajax_create(name)
    assert_equal(expected_count, @container_class.count)
  end
  
  def ajax_create(name)
    xhr :post, :create, @container_class.name.downcase.to_sym => {:name => name}
  end  
  
end
