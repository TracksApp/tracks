require File.dirname(__FILE__) + '/../test_helper'

class ContextTest < ActiveSupport::TestCase
  fixtures :contexts, :todos, :recurring_todos, :users, :preferences

  def setup
    @agenda = contexts(:agenda)
    @email = contexts(:email)
    @library = contexts(:library)
  end

  def test_validate_presence_of_name
     @agenda.name = ""
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context must have a name", @agenda.errors.on(:name)
  end
     
  def test_validate_name_is_less_than_256
     @agenda.name = "a"*256
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context name must be less than 256 characters", @agenda.errors.on(:name)
   end
     
  def test_validate_name_is_unique
     newcontext = Context.new
     newcontext.name = contexts(:agenda).name
     newcontext.user_id = contexts(:agenda).user_id
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "already exists", newcontext.errors.on(:name)
  end
  
  def test_validate_name_does_not_contain_comma
     newcontext = Context.new
     newcontext.name = "phone,telegraph"
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "cannot contain the comma (',') character", newcontext.errors.on(:name)
  end
  
  def test_find_by_namepart_with_exact_match
    c = Context.find_by_namepart('agenda')
    assert_not_nil c
    assert_equal @agenda.id, c.id
  end

  def test_find_by_namepart_with_starts_with
    c = Context.find_by_namepart('agen')
    assert_not_nil c
    assert_equal @agenda.id, c.id
  end
  
  def test_delete_context_deletes_todos_within_it
    assert_equal 7, @agenda.todos.count
    agenda_todo_ids = @agenda.todos.collect{|t| t.id }
    @agenda.destroy
    agenda_todo_ids.each do |todo_id|
      assert !Todo.exists?(todo_id)
    end
  end
  
  def test_not_done_todos
    assert_equal 6, @agenda.not_done_todos.size
    t = @agenda.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 5, Context.find(@agenda.id).not_done_todos.size
  end
    
  def test_done_todos
    assert_equal 1, @agenda.done_todos.size
    t = @agenda.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 2, Context.find(@agenda.id).done_todos.size
  end
  
  def test_to_param_returns_id
    assert_equal '1', @agenda.to_param
  end
    
  def test_title_reader_returns_name
    assert_equal @agenda.name, @agenda.title
  end

  def test_feed_options
    opts = Context.feed_options(users(:admin_user))
    assert_equal 'Tracks Contexts', opts[:title], 'Unexpected value for :title key of feed_options'
    assert_equal 'Lists all the contexts for Admin Schmadmin', opts[:description], 'Unexpected value for :description key of feed_options'
  end

  def test_hidden_attr_reader
    assert !@agenda.hidden?
    @agenda.hide = true
    @agenda.save!
    @agenda.reload
    assert_equal true, @agenda.hidden?
  end

  def test_summary
    undone_todo_count = '5 actions'
    assert_equal "<p>#{undone_todo_count}. Context is Active.</p>", @agenda.summary(undone_todo_count)
    @agenda.hide = true
    @agenda.save!
    assert_equal "<p>#{undone_todo_count}. Context is Hidden.</p>", @agenda.summary(undone_todo_count)
  end

  def test_null_object
    c = Context.null_object
    assert c.nil?
    assert_nil c.id
    assert_equal '', c.name
  end

end
