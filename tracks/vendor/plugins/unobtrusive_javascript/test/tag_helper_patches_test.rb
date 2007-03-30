require File.dirname(__FILE__) + '/test_helper'

class ContentTagWithJavascriptEventsTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @output = content_tag('div', 'my test div', {
      :id => 'my_test_div', :class => 'some_class',
      :onclick => 'alert("foo")',
      :onmouseup => 'alert("foo")',
      :onmousedown => 'alert("foo")',
      :ondblclick => 'alert("foo")',
      :onmouseover => 'alert("foo")',
      :onmouseout => 'alert("foo")',
      :onload => 'alert("foo")',
      :onmousemove => 'alert("foo")'
    })
  end
  
  def test_result_should_not_contain_any_inline_javascript_events
    assert_equal '<div class="some_class" id="my_test_div">my test div</div>', @output
  end
  
  def test_should_have_javascript_events_registered_as_unobtrusive
    assert_equal 8, assigns(:js_behaviours).rules.size
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:click', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:mouseup', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:mousedown', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:dblclick', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:mouseover', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:mouseout', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:load', 'alert("foo");'])
    assert assigns(:js_behaviours).rules.include?(['#my_test_div:mousemove', 'alert("foo");'])
  end
end

class TagOptionsForFormTextFieldsTest < Test::Unit::TestCase
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  
  def setup
    @controller = ControllerStub.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    get :index
    @text_field_tag = text_field_tag('login')
    @text_field = text_field(:user, :first_name)
  end
  
  def test_should_not_contain_any_inline_javascript_events
    assert_equal '<input id="login" name="login" type="text" />', @text_field_tag
    assert_equal '<input id="user_first_name" name="user[first_name]" size="30" type="text" />', @text_field
  end
end