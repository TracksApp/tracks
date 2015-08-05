require 'test_helper'

class MessageGatewayTest < ActiveSupport::TestCase

  def setup
    @user = users(:sms_user)
    @inbox = contexts(:inbox)
  end

  def load_message(filename)
    MessageGateway.receive(File.read(File.join(Rails.root, 'test', 'fixtures', filename)))
  end

  def test_sms_with_no_subject
    todo_count = Todo.count

    load_message('sample_sms.txt')
    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.where(:description => "message_content").first
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
  end

  def test_mms_with_subject
    todo_count = Todo.count

    load_message('sample_mms.txt')

    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.where(:description => "This is the subject").first
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
    assert_equal("This is the message body", message_todo.notes)
  end

  def test_email_with_winmail_dat
    todo_count = Todo.count

    load_message('email_with_winmail.txt')

    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)
  end

  def test_email_with_multipart_attachments
    todo_count = Todo.count

    load_message('email_with_multipart.txt')

    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)
  end

  def test_no_user
    todo_count = Todo.count
    badmessage = File.read(File.join(Rails.root, 'test', 'fixtures', 'sample_sms.txt'))
    badmessage.gsub!("5555555555", "notauser")
    MessageGateway.receive(badmessage)
    assert_equal(todo_count, Todo.count)
  end

  def test_direct_to_context
    message = File.read(File.join(Rails.root, 'test', 'fixtures', 'sample_sms.txt'))

    valid_context_msg = message.gsub('message_content', 'this is a task @ anothercontext')
    invalid_context_msg = message.gsub('message_content', 'this is also a task @ notacontext')

    MessageGateway.receive(valid_context_msg)
    valid_context_todo = Todo.where(:description => "this is a task").first
    assert_not_nil(valid_context_todo)
    assert_equal(contexts(:anothercontext), valid_context_todo.context)

    MessageGateway.receive(invalid_context_msg)
    invalid_context_todo = Todo.where(:description => 'this is also a task').first
    assert_not_nil(invalid_context_todo)
    assert_equal(@inbox, invalid_context_todo.context)
  end

  def test_receiving_email_adds_attachment
    attachment_count = Attachment.count

    load_message('sample_mms.txt')

    message_todo = Todo.where(:description => "This is the subject").first
    assert_not_nil(message_todo)

    assert_equal attachment_count+1, Attachment.count
    assert_equal 1,message_todo.attachments.count

    orig = File.read(File.join(Rails.root, 'test', 'fixtures', 'sample_mms.txt'))
    attachment = File.read(message_todo.attachments.first.file.path)

    assert_equal orig, attachment
  end
end
