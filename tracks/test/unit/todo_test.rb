require File.dirname(__FILE__) + '/../test_helper'
require 'date'

class TodoTest < Test::Unit::TestCase
  fixtures :todos

  def setup
    @not_completed1 = Todo.find(1)
    @not_completed2 = Todo.find(2)
    @completed = Todo.find(8)
  end
  
  # Test loading a todo item
  def test_load
    assert_kind_of Todo, @not_completed1
    assert_equal 1, @not_completed1.id
    assert_equal 1, @not_completed1.context_id
    assert_equal 2, @not_completed1.project_id
    assert_equal "Call Bill Gates to find out how much he makes per day", @not_completed1.description
    assert_nil @not_completed1.notes
    assert_equal false, @not_completed1.done
    assert_equal "2004-11-28 16:01:00", @not_completed1.created_at.strftime("%Y-%m-%d %H:%M:%S")
    assert_equal "2004-10-30", @not_completed1.due.strftime("%Y-%m-%d")
    assert_nil @not_completed1.completed
    assert_equal 1, @not_completed1.user_id
  end
  
  def test_completed
    assert_kind_of Todo, @completed
    assert_equal true, @completed.done
    assert_not_nil @completed.completed
  end
  
  # Validation tests
  #
  def test_validate_presence_of_description
    assert_equal "Call dinosaur exterminator", @not_completed2.description
    @not_completed2.description = ""
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "can't be blank", @not_completed2.errors.on(:description)
  end
  
  def test_validate_length_of_description
    assert_equal "Call dinosaur exterminator", @not_completed2.description
    @not_completed2.description = generate_random_string(101)
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "is too long (max is 100 characters)", @not_completed2.errors.on(:description)
  end
  
  def test_validate_length_of_notes
    assert_equal "Ask him if I need to hire a skip for the corpses.", @not_completed2.notes
    @not_completed2.notes = generate_random_string(60001)
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "is too long (max is 60000 characters)", @not_completed2.errors.on(:notes)
  end
end
