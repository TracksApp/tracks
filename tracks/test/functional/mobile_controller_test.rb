require File.dirname(__FILE__) + '/../test_helper'
require 'mobile_controller'

# Re-raise errors caught by the controller.
class MobileController; def rescue_action(e) raise e end; end

class MobileControllerTest < Test::Unit::TestCase
    fixtures :users, :preferences, :projects, :contexts, :todos
    
  def setup
    @controller = MobileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_create_item
    @count = Todo.find(:all)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :_source_view => 'todo', "item"=>{"context_id"=>"1", "project_id"=>"2", "notes"=>"", "description"=>"Invest in spam stock offer", "due"=>"01/01/2007"}
    @todos = Todo.find(:all)
    assert_equal @count.size+1, @todos.size
    t = Todo.find(15)
    assert_equal "Invest in spam stock offer", t.description
    assert_equal Date.parse("01/01/2007"), t.due
    assert_equal users(:admin_user).id, t.user_id
    assert_equal 1, t.context_id
    assert_equal 2, t.project_id
    assert_equal "active", t.state
  end
  
  def test_update_item
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "item"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"11/30/2006"}
    t = Todo.find(1)
    assert_equal "Call Warren Buffet to find out how much he makes per day", t.description
    assert_equal Date.parse("11/30/2006"), t.due
    assert_equal users(:admin_user).id, t.user_id
    assert_equal "active", t.state
  end
  
  def test_complete_item
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "item"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Bill Gates to find out how much he makes per day", "state"=>"1"}
    t = Todo.find(1)
    assert_equal "completed", t.state
  end
end
