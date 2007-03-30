require File.dirname(__FILE__) + '/test_helper'

class ApplyingBehaviourWithStringOfJavascriptTest < Test::Unit::TestCase
  include UJS::Helpers
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @output = apply_behaviour("#mydiv:click", "alert('hello world')")
  end
  
  def test_should_store_registered_behaviour
    assert_equal 1, assigns(:js_behaviours).rules.size
    assert_equal "#mydiv:click", assigns(:js_behaviours).rules.first[0]
    assert_equal "alert('hello world');", assigns(:js_behaviours).rules.first[1]
  end
end

class ApplyingBehaviourThatIsRendererdInlineTest < Test::Unit::TestCase
  include UJS::Helpers
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::TagHelper
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @output = apply_behaviour("#mydiv:click", "alert('hello world')", :external => false)
  end
  
  def test_should_not_store_registered_behaviour
    assert_equal 0, assigns(:js_behaviours).rules.size
  end
end

class PreventDefaultBehaviourOptionTest < Test::Unit::TestCase
  include UJS::Helpers
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::TagHelper
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @output = apply_behaviour("#mydiv:click", "alert('hello world')", :prevent_default => true)
  end
  
  def test_should_return_false_with_prevent_default
    assert_equal ['#mydiv:click', "alert('hello world'); return false;"], assigns(:js_behaviours).rules.last
  end
end

class ApplyingBehaviourWithBlockTest < Test::Unit::TestCase
  include UJS::Helpers
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
  end
  
  def test_should_use_page_argument
    apply_behaviour '#thing' do |page|
      page.alert('hello')
    end
    
    assert_equal '#thing', assigns(:js_behaviours).rules.last[0]
    assert_equal "alert(\"hello\");", assigns(:js_behaviours).rules.last[1]
  end
  
  def test_should_use_element_argument
    apply_behaviour '#thing' do |page, element|
      element.hide
    end
    
    assert_equal '#thing', assigns(:js_behaviours).rules.last[0]
    assert_equal "this.hide();", assigns(:js_behaviours).rules.last[1]
  end
  
  def test_should_use_event_argument
    apply_behaviour '#thing' do |page, element, event|
      event.stop
    end
    
    assert_equal '#thing', assigns(:js_behaviours).rules.last[0]
    assert_equal "Event.stop(event);", assigns(:js_behaviours).rules.last[1]
  end
  
  def test_should_use_allow_multiple_calls
    apply_behaviour '#thing' do |page, element, event|
      page.alert('hiding thing')
      element.hide
      element.show
      event.stop
    end
    
    assert_equal '#thing', assigns(:js_behaviours).rules.last[0]
    assert_equal "alert(\"hiding thing\");\nthis.hide();\nthis.show();\nEvent.stop(event);", assigns(:js_behaviours).rules.last[1]
  end
  
  def test_should_allow_options_with_block_without_specifying_string
    apply_behaviour '#thing2', :prevent_default => true do |page|
      page.alert('boo')
    end
    
    assert_equal '#thing2', assigns(:js_behaviours).rules.last[0]
    assert_equal "alert(\"boo\"); return false;", assigns(:js_behaviours).rules.last[1]
  end
  
  def test_should_allow_element_proxy_methods_to_be_called
    apply_behaviour '#thing3' do |page, element|
      element.replace_html '<strong>Wow!</strong>'
    end
    
    assert_equal '#thing3', assigns(:js_behaviours).rules.last[0]
    assert_equal "this.update(\"<strong>Wow!</strong>\");", assigns(:js_behaviours).rules.last[1]
  end
end

class MultipleBehavioursAppliedAtOnceTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  include UJS::Helpers
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    apply_behaviours do
      on "div.foo", "alert('foo')"
      on "div.bar", "alert('bar')"
    end
  end
  
  def test_should_all_get_registered_in_the_behaviour_script
    assert_equal 2, assigns(:js_behaviours).rules.size
  end
  
  def test_should_work_with_apply_behaviour_helpers
    apply_behaviours do
      on "ul.sortable", make_sortable
    end
    assert_equal 3, assigns(:js_behaviours).rules.size
  end
end

class MultipleBehavioursAppliedAtOnceWithExternalFalseTest < Test::Unit::TestCase
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include UJS::BehaviourHelper
  include UJS::Helpers
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @output = apply_behaviours do
      on "div.foo", "alert('foo')", :external => false
      on "div.bar", :external => false do |page|
        page.alert('bar')
      end
    end
  end
  
  def test_should_output_behaviours
    assert_not_equal '', @output
    assert_match(/<script/, @output)
    assert_match(/alert\('foo'\)/, @output)
    assert_match(/alert\("bar"\)/, @output)
  end
end

