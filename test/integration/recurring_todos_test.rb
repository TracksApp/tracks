require 'test_helper'

class RecurringTodosTest < ActionDispatch::IntegrationTest

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
    assert_equal 1, rt.todos.size     # and it has one todo referencing it

    # when I toggle the todo complete
    todo = Todo.where(:recurring_todo_id => 1).first
    put "/todos/#{todo.id}/toggle_check", :_source_view => 'todo'
    todo.reload
    assert todo.completed?

    rt.reload                   # then there should be two todos referencing
    assert_equal 2, rt.todos.size
    todo2 = Todo.where(:recurring_todo_id => rt.id, :state => 'active').first
    assert_not_equal todo2.id, todo.id # and the todos should be different

    # when I delete the recurring todo
    delete_via_redirect "/recurring_todos/#{rt.id}", :_source_view => 'todo'

    todo.reload
    todo2.reload

    assert todo.recurring_todo_id.nil?
    assert todo2.recurring_todo_id.nil?
  end
end