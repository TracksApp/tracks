require 'test_helper'

class RecurringTodosTest < ActionDispatch::IntegrationTest

  def test_deleting_recurring_todo_clears_reference_from_related_todos
    logs_in_as(users(:admin_user), 'abracadabra')

    rt = RecurringTodo.find(1)
    assert !rt.nil?             # given there is a recurring todo
    assert_equal 1, rt.todos.size     # and it has one todo referencing it

    # when I toggle the todo complete
    todo = Todo.where(:recurring_todo_id => 1).first
    put "/todos/#{todo.id}/toggle_check", params: { :_source_view => 'todo' }
    todo.reload
    assert todo.completed?

    rt.reload                   # then there should be two todos referencing
    assert_equal 2, rt.todos.size
    todo2 = Todo.where(:recurring_todo_id => rt.id, :state => 'active').first
    refute_equal todo2.id, todo.id # and the todos should be different

    # when I delete the recurring todo
    delete "/recurring_todos/#{rt.id}", params: { :_source_view => 'todo' }
    follow_redirect!

    todo.reload
    todo2.reload

    assert todo.recurring_todo_id.nil?
    assert todo2.recurring_todo_id.nil?
  end
end
