require File.dirname(__FILE__) + '/../test_helper'

class SMSGatewayTest < Test::Rails::TestCase
  fixtures :users, :contexts

  def setup
    @user = users(:sms_user)
    @inbox = contexts(:inbox)
  end

  def load_message(filename)
    SMSGateway.receive(File.read(File.join(RAILS_ROOT, 'test', 'fixtures', filename)))
  end

  def test_sms_with_no_subject
    todo_count = Todo.count

    load_message('sample_sms.txt')
    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.find(:first, :conditions => {:description => "This is a todo 4112093"})
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
  end

  def test_double_sms
    todo_count = Todo.count
    load_message('sample_sms.txt')
    load_message('sample_sms.txt')
    assert_equal(todo_count+1, Todo.count)
  end

  def test_mms_with_subject
    todo_count = Todo.count

    load_message('sample_mms.txt')

    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.find(:first, :conditions => {:description => "This is the subject"})
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
    assert_equal("This is the message body", message_todo.notes)
  end
end
