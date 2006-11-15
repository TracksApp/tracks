require File.dirname(__FILE__) + '/../test_helper'
require 'todo_controller'

# Re-raise errors caught by the controller.
class TodoController; def rescue_action(e) raise e end; end

class TodoControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos
  
  def setup
    @controller = TodoController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_not_done_counts
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_not_done_counts_after_hiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal nil, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 2, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal nil, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_not_done_counts_after_hiding_and_unhiding_project
    p = Project.find(1)
    p.hide!
    p.save!
    p.activate!
    p.save!
    @request.session['user_id'] = users(:admin_user).id
    get :index
    assert_equal 2, assigns['project_not_done_counts'][projects(:timemachine).id]
    assert_equal 3, assigns['context_not_done_counts'][contexts(:call).id]
    assert_equal 1, assigns['context_not_done_counts'][contexts(:lab).id]
  end
  
  def test_destroy_item
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    assert_rjs :page, "item-1-container", :remove
    #assert_rjs :replace_html, "badge-count", '9' 
  end
  
  def test_update_item
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "item"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"11/30/2006"}
    #assert_rjs :page, "item-1-container", :visual_effect, :highlight, :duration => '1'
    t = Todo.find(1)
    assert_equal "Call Warren Buffet to find out how much he makes per day", t.description
    assert_equal Date.parse("11/30/2006"), t.due
  end
  

end
