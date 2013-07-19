require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

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

end
