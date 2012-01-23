require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'date'

class TodoTest < ActiveSupport::TestCase
  fixtures :todos, :recurring_todos, :users, :contexts, :preferences, :tags, :taggings, :projects

  def setup
    @not_completed1 = Todo.find(1).reload
    @not_completed2 = Todo.find(2).reload
    @completed = Todo.find(8).reload
  end

  # test named_scopes
  def test_find_completed
    # Given 2 completed todos, one completed now and one completed 2 months ago
    @not_completed1.toggle_completion!
    @completed.completed_at = 2.months.ago
    @completed.save!

    completed_old = @completed
    completed_now = @not_completed1

    # When I use the finders
    recent_completed_todos = Todo.completed_after(1.month.ago).find(:all)
    older_completed_todos = Todo.completed_before(1.month.ago).find(:all)

    # Then completed1 should be before and completed2 should be after a month ago
    assert older_completed_todos.include?(completed_old)
    assert recent_completed_todos.include?(completed_now)

    # And completed1 should not be after and completed2 should not be before a month ago
    assert !older_completed_todos.include?(completed_now)
    assert !recent_completed_todos.include?(completed_old)
  end

  def test_find_created
    # Given 2 created todos, one created now and one created 2 months ago
    user = @completed.user
    todo_old = user.todos.create!({:description => "created long long ago", :context => @completed.context})
    todo_old.created_at = 2.months.ago
    todo_old.save!
    todo_now = user.todos.create!({:description => "just created", :context => @completed.context})

    # When I use the finders
    recent_created_todos = Todo.created_after(1.month.ago).find(:all)
    older_created_todos = Todo.created_before(1.month.ago).find(:all)

    # Then todo1 should be before and todo2 should be after a month ago
    assert older_created_todos.include?(todo_old)
    assert recent_created_todos.include?(todo_now)

    # And todo1 should not be after and todo2 should not be before a month ago
    assert !older_created_todos.include?(todo_now)
    assert !recent_created_todos.include?(todo_old)
  end

end