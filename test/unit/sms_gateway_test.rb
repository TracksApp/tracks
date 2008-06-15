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

    message_todo = Todo.find(:first, :conditions => {:description => "message_content"})
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

  def test_no_user
    todo_count = Todo.count
    badmessage = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))
    badmessage.gsub!("5555555555", "notauser")
    SMSGateway.receive(badmessage)
    assert_equal(todo_count, Todo.count)
  end

  def test_direct_to_context
    message = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))

    valid_context_msg = message.gsub('message_content', 'anothercontext: this is a task')
    invalid_context_msg = message.gsub('message_content', 'notacontext: this is a task')

    SMSGateway.receive(valid_context_msg)
    valid_context_todo = Todo.find(:first, :conditions => {:description => "this is a task"})
    assert_not_nil(valid_context_todo)
    assert_equal(contexts(:anothercontext), valid_context_todo.context)

    SMSGateway.receive(invalid_context_msg)
    invalid_context_todo = Todo.find(:first, :conditions => {:description => 'notacontext: this is a task'})
    assert_not_nil(invalid_context_todo)
    assert_equal(@inbox, invalid_context_todo.context)
  end

  def test_due_date
    message = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))

    valid_due_msg1 = message.gsub('message_content', 'do something tomorrow due:6/15/2008')
    valid_due_msg2 = message.gsub('message_content', 'do something tomorrow due:6/28/2008 and remember it!')
    valid_due_msg3 = message.gsub('message_content', 'due:1/28/2008 funky!')
    invalid_due_msg1 = message.gsub('message_content', 'do something tomorrow due:xxxx and remember it!')

    SMSGateway.receive(valid_due_msg1)
    valid_due_todo1 = Todo.find(:first, :conditions => {:description => "do something tomorrow"})
    assert_not_nil(valid_due_todo1)
    assert_equal(Date.civil(2008, 6, 15), valid_due_todo1.due)

    SMSGateway.receive(valid_due_msg2)
    valid_due_todo2 = Todo.find(:first, :conditions => {:description => "do something tomorrow and remember it!"})
    assert_not_nil(valid_due_todo2)
    assert_equal(Date.civil(2008, 6, 28), valid_due_todo2.due)

    SMSGateway.receive(valid_due_msg3)
    valid_due_todo3 = Todo.find(:first, :conditions => {:description => "funky!"})
    assert_not_nil(valid_due_todo3)
    assert_equal(Date.civil(2008, 1, 28), valid_due_todo3.due)

    SMSGateway.receive(invalid_due_msg1)
    invalid_due_todo1 = Todo.find(:first, :conditions => {:description => "do something tomorrow due:xxxx and remember it!"})
    assert_not_nil(invalid_due_todo1)
    assert_nil(invalid_due_todo1.due)
  end

  def test_show_date
    message = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))

    valid_show_msg1 = message.gsub('message_content', "do something tomorrow show:#{Date.tomorrow.to_s}")
    valid_show_msg2 = message.gsub('message_content', "do something next week show:#{Date.today.next_week.to_s} and remember it!")
    valid_show_msg3 = message.gsub('message_content', "show:#{Date.tomorrow.to_s} alternative format")
    invalid_show_msg1 = message.gsub('message_content', 'do something tomorrow show:xxxx and remember it!')

    SMSGateway.receive(valid_show_msg1)
    valid_show_todo1 = Todo.find(:first, :conditions => {:description => "do something tomorrow"})
    assert_not_nil(valid_show_todo1)
    assert_equal(Date.tomorrow, valid_show_todo1.show_from)

    SMSGateway.receive(valid_show_msg2)
    valid_show_todo2 = Todo.find(:first, :conditions => {:description => "do something next week and remember it!"})
    assert_not_nil(valid_show_todo2)
    assert_equal(Date.tomorrow.next_week, valid_show_todo2.show_from)

    SMSGateway.receive(valid_show_msg3)
    valid_show_todo3 = Todo.find(:first, :conditions => {:description => "alternative format"})
    # p @user.todos.last
    assert_not_nil(valid_show_todo3)
    assert_equal(Date.tomorrow, valid_show_todo3.show_from)

    SMSGateway.receive(invalid_show_msg1)
    invalid_show_todo1 = Todo.find(:first, :conditions => {:description => "do something tomorrow show:xxxx and remember it!"})
    assert_not_nil(invalid_show_todo1)
    assert_nil(invalid_show_todo1.show_from)
  end
end
