require File.dirname(__FILE__) + '/test_helper'

class ControllerWithControllerMethodsInjected < Test::Unit::TestCase
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
  end
  
  def test_should_add_a_before_filter_that_creates_a_new_behaviour_script
    assert ControllerStub.before_filters.include?(:initialise_js_behaviours)
    assert_instance_of UJS::BehaviourScript, assigns(:js_behaviours)
    assert_equal "", assigns(:js_behaviours).to_s
  end
  
  def test_should_store_applied_behaviours_in_the_behaviour_script
    @controller.apply_behaviour("div.foo", "alert('foo')")
    assert_equal 1, assigns(:js_behaviours).rules.size
  end
  
  def test_should_add_an_after_filter_that_stores_the_behaviour_script_in_the_session_as_a_hash
    assert ControllerStub.after_filters.include?(:store_js_behaviours)
    assert_equal session[:js_behaviours], assigns(:js_behaviours).to_hash
  end
  
  def test_should_not_store_behaviour_script_in_the_session_if_js_behaviours_is_nil
    @controller.send(:reset_js_behaviours)
    assert_nil @controller.send(:js_behaviours)
  end
  
  def test_should_turn_behaviour_script_caching_on_when_cache_behaviours_is_called
    @controller.cache_behaviours
    assert assigns(:js_behaviours).cache?
  end
  
  def test_should_toggle_reload_after_ajax_when_set
    @controller.reapply_behaviours_after_ajax = false
    assert !assigns(:js_behaviours).reapply_after_ajax?
    @controller.reapply_behaviours_after_ajax = true
    assert assigns(:js_behaviours).reapply_after_ajax?
  end
  
  def test_should_also_allow_american_spelling_for_apply_behaviour
    @controller.apply_behavior("div.foo", "alert('foo')")
    assert_equal 1, assigns(:js_behaviours).rules.size
  end
end