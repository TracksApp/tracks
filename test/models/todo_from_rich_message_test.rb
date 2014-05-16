require 'test_helper'

class TodoFromRichMessageTest < ActiveSupport::TestCase

  def setup
    @completed = Todo.find(8)
  end

  def test_from_rich_message_adds_to_default_context
    user = @completed.user
    default_context_id = @completed.context_id
    builder = TodoFromRichMessage.new(user, default_context_id, "new todo", "notes")
    new_todo = builder.construct

    assert_not_nil new_todo
    assert_equal "new todo", new_todo.description
    assert_equal "notes", new_todo.notes
    assert_equal default_context_id, new_todo.context_id
  end

  def test_from_rich_message_adds_all_fields
    user = @completed.user
    context = Context.create(:name => 'context')
    project = Project.create(:name => 'project')
    message = "description@context~project>131014<131017#tag1#tag2*"
    builder = TodoFromRichMessage.new(user, context.id, message, "notes")
    new_todo = builder.construct

    assert_not_nil new_todo
    assert_equal "description", new_todo.description
    assert_equal "notes", new_todo.notes
    assert_equal context.id, new_todo.context_id
    assert_equal project.id, new_todo.project_id
    assert_equal Time.zone.parse("2013-10-14 00:00"). utc.to_s, new_todo.show_from.utc.to_s
    assert_equal Time.zone.parse("2013-10-17 00:00"), new_todo.due.utc.to_s
    assert_equal "starred, tag1, tag2", new_todo.tags.to_s
    assert new_todo.starred?
  end

end
