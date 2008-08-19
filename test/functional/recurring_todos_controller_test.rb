require File.dirname(__FILE__) + '/../test_helper'

class RecurringTodosControllerTest < ActionController::TestCase
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings, :recurring_todos
  
  def setup
    @controller = RecurringTodosController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_get_index_when_not_logged_in
    get :index
    assert_redirected_to :controller => 'login', :action => 'login'
  end
  
  def test_destroy_recurring_todo
    login_as(:admin_user)
    xhr :post, :destroy, :id => 1, :_source_view => 'todo'
    assert_rjs :page, "recurring_todo_1", :remove
  end

end
