require File.dirname(__FILE__) + '/test_helper'

class SetupTest < Test::Unit::TestCase
  def setup
    @controller = SeleniumController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_session_reset
    @request.session['key'] = 'value'
    get :setup
    assert_nil session['key']
    assert_response :success
    assert_tag :content => 'The session is wiped clean.'
  end
  
  def test_session_no_reset
    @request.session['key'] = 'value'
    get :setup, :keep_session => true
    assert_equal 'value', session['key']
    assert_response :success
    assert_no_tag :content => 'The session is wiped clean.'
  end
  
  #
  # Don't have the nerve to test fixtures since this is a plugin
  #
end
