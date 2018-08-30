require 'test_helper'
require_relative '../../lib/project_from_todo'

class ProjectFromTodoTest < ActiveSupport::TestCase
  fixtures :todos

  def test_create_project_from_valid_todo
    todo = todos(:upgrade_rails)
    project = ProjectFromTodo.new(todo).create
    assert_equal project.name, todo.description
    if project.description.nil?
        assert_nil todo.notes
    else
        assert_equal project.description, todo.notes
    end
    if project.default_context.nil?
        assert_nil todo.context
    else
        assert_equal project.default_context, todo.context
    end
  end

  def test_retain_tags_from_todo
    todo = todos(:upgrade_rails)
    todo.tag_with "a, b"
    project = ProjectFromTodo.new(todo).create
    assert_equal "a, b", project.default_tags
  end

  def test_project_is_marked_as_reviewed
    todo = todos(:upgrade_rails)
    project = ProjectFromTodo.new(todo).create
    refute project.needs_review?(users(:admin_user))
  end

  def test_invalid_project_from_invalid_todo
    todo = todos(:upgrade_rails)
    todo.description = ""
    project = ProjectFromTodo.new(todo).create
    assert_not_nil project
    assert_equal false, project.valid?
  end
end
