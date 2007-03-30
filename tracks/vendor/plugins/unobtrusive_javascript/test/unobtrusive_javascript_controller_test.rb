require File.dirname(__FILE__) + '/test_helper'

# inject the controller methods to add the appropriate filters
# before loading in the unobtrusive js controller otherwise its
# skip_ filters will be fubarred.
ActionController::Base.send(:include, UJS::ControllerMethods)

require 'controllers/unobtrusive_javascript_controller'

class BehaviourGenerationControllerTest < Test::Unit::TestCase
  def test_should_always_skip_the_initialise_js_behaviours_filter
    assert !UnobtrusiveJavascriptController.before_filters.include?(:initialise_js_behaviours)
  end
  
  def test_should_always_skip_the_store_js_behaviours_filter
    assert !UnobtrusiveJavascriptController.before_filters.include?(:store_js_behaviours)
  end
  
  def test_should_always_perform_any_caching_after_a_request
    assert UnobtrusiveJavascriptController.after_filters.include?(:perform_any_caching)
  end
  
  def test_should_always_reset_any_js_behaviours_after_a_request
    assert UnobtrusiveJavascriptController.after_filters.include?(:reset_js_behaviours)
  end
end

class BehaviourGenerationWithNoBehavioursTest < Test::Unit::TestCase
  def setup
    @controller = UnobtrusiveJavascriptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    UnobtrusiveJavascriptController.any_instance.stubs(:js_behaviours).returns(UJS::BehaviourScript.new)
    get :generate
  end
  
  def test_should_set_content_type_to_text_javascript
    assert_equal "text/javascript", @response.headers["Content-Type"]
  end
  
  def test_should_render_nothing
    assert_equal "", @response.body
  end
end

class BehaviourGenerationWithAppliedBehavioursTest < Test::Unit::TestCase
  def setup
    @behaviours = UJS::BehaviourScript.new
    @behaviours.add_rule("div.foo", "alert('foo')")
    @behaviours.add_rule("div.bar", "alert('bar')")
    UnobtrusiveJavascriptController.any_instance.stubs(:js_behaviours).returns(@behaviours)
    @controller = UnobtrusiveJavascriptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :generate
  end
  
  def test_should_set_content_type_to_text_javascript
    assert_equal "text/javascript", @response.headers["Content-Type"]
  end
  
  def test_should_render_behaviour_script_output
    assert_equal @behaviours.to_s, @response.body
  end
  
  def test_should_generate_an_etag_for_the_behaviours
    assert_equal Digest::MD5.hexdigest(@behaviours.to_s), @response.headers["ETag"]
  end
end

class BehaviourGenerationWithUnchangedBehavioursTest < Test::Unit::TestCase
  def setup
    @behaviours = UJS::BehaviourScript.new
    @behaviours.add_rule("div.foo", "alert('foo')")
    @behaviours.add_rule("div.bar", "alert('bar')")
    UnobtrusiveJavascriptController.any_instance.stubs(:js_behaviours).returns(@behaviours)
    @controller = UnobtrusiveJavascriptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.env['HTTP_IF_NONE_MATCH'] = Digest::MD5.hexdigest(@behaviours.to_s)
    get :generate
  end
  
  def test_should_set_content_type_to_text_javascript
    assert_equal "text/javascript", @response.headers["Content-Type"]
  end
  
  def test_should_render_nothing
    assert_equal " ", @response.body
  end
  
  def test_should_send_304_not_modified_http_status
    assert_response 304
  end
end