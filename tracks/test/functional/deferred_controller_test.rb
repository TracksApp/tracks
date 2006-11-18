require File.dirname(__FILE__) + '/../test_helper'
require 'deferred_controller'

# Re-raise errors caught by the controller.
class DeferredController; def rescue_action(e) raise e end; end

class DeferredControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos
  
  def setup
    @controller = DeferredController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end
  
  def test_create
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :create, :todo => {:description => 'deferred controller test create', :notes => 'notes', :context_id => 1, :project_id => 1, :due => '', :show_from => '11/30/2030'}
    t = Todo.find_by_description('deferred controller test create')
    assert_equal :deferred, t.current_state.to_sym
  end

end
