require File.dirname(__FILE__) + '/../test_helper'
require 'todos_controller'

# Re-raise errors caught by the controller.
class TodosController; def rescue_action(e) raise e end; end

class TodosControllerTest < Test::Unit::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings
  
  def setup
    @controller = TodosController.new
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
  
  def test_deferred_count_for_project_source_view
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :toggle_check, :id => 5, :_source_view => 'project' 
    assert_equal 1, assigns['deferred_count']
    xhr :post, :toggle_check, :id => 15, :_source_view => 'project' 
    assert_equal 0, assigns['deferred_count']
  end
  
  def test_destroy_item
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    assert_rjs :page, "todo_1", :remove
    #assert_rjs :replace_html, "badge-count", '9' 
  end
  
  def test_update_item_project
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"Build a working time machine", "item"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_equal 1, t.project_id
  end
  
  def test_update_item_project_to_none
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "context_name"=>"library", "project_name"=>"None", "item"=>{"id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    t = Todo.find(1)
    assert_nil t.project_id
  end
  
  def test_update_item
    t = Todo.find(1)
    @request.session['user_id'] = users(:admin_user).id
    xhr :post, :update, :id => 1, :_source_view => 'todo', "item"=>{"context_id"=>"1", "project_id"=>"2", "id"=>"1", "notes"=>"", "description"=>"Call Warren Buffet to find out how much he makes per day", "due"=>"30/11/2006"}, "tag_list"=>"foo bar"
    #assert_rjs :page, "todo_1", :visual_effect, :highlight, :duration => '1'
    t = Todo.find(1)
    assert_equal "Call Warren Buffet to find out how much he makes per day", t.description
    expected = Date.new(2006,11,30).to_time.utc.to_date
    actual = t.due
    assert_equal expected, actual, "Expected #{expected.to_s(:db)}, was #{actual.to_s(:db)}"
  end
  
  def test_tag
    @request.session['user_id'] = users(:admin_user).id
    @user = User.find(@request.session['user_id'])
    @tagged = Todo.find_tagged_with('foo', @user).size
    get :tag, :id => 'foo'
    assert_response :success
    assert_equal 2, @tagged
  end
  

end
