require File.dirname(__FILE__) + '/../test_helper'
require 'todos_controller'
require 'recurring_todos_controller'

class RecurringTodosTest < ActionController::IntegrationTest
  fixtures :users, :preferences, :projects, :contexts, :todos, :tags, :taggings, :recurring_todos

  def logs_in_as(user,plain_pass)
    @user = user
    post "/login", :user_login => @user.login,
      :user_password => plain_pass,
      :user_noexpiry => 'n'
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "todos/index"
  end


  def test_deleting_recurring_todo_clears_reference_from_related_todos
    logs_in_as(users(:admin_user), 'abracadabra')

    rt = RecurringTodo.find(1)
    assert !rt.nil?             # given there is a recurring todo
    assert rt.todos.size, 1     # and it has one todos referencing it

    # when I toggle the todo complete
    todo = Todo.find_by_recurring_todo_id(1)
    post "/todos/toggle_check/#{todo.id}", :_source_view => 'todo'
    todo.reload
    assert todo.completed?

    rt.reload                   # then there should be two todos referencing
    assert rt.todos.size, 2
    todo2 = Todo.find(:first, :conditions => {:recurring_todo_id => rt.id, :state => 'active'})
    assert_not_equal todo2.id, todo.id # and the todos should be different

    # when I delete the recurring todo
    delete_via_redirect "/recurring_todos/#{rt.id}", :_source_view => 'todo'

    todo.reload
    todo2.reload

    assert todo.recurring_todo_id.nil?
    assert todo2.recurring_todo_id.nil?
  end
end