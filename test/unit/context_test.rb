require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContextTest < ActiveSupport::TestCase
  fixtures :contexts, :todos, :recurring_todos, :users, :preferences

  def setup
    @agenda = contexts(:agenda)
    @email = contexts(:email)
    @library = contexts(:library)
  end

  def test_uses_acts_as_list
    # only check that acts_as_list is present in the model
    assert @agenda.respond_to?(:move_to_bottom)
  end
  
  def test_validate_presence_of_name
     @agenda.name = ""
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context must have a name", @agenda.errors[:name][0]
  end
     
  def test_validate_name_is_less_than_256
     @agenda.name = generate_random_string(256)
     assert !@agenda.save
     assert_equal 1, @agenda.errors.count
     assert_equal "context name must be less than 256 characters", @agenda.errors[:name][0]
   end
     
  def test_validate_name_is_unique
     newcontext = Context.new
     newcontext.name = contexts(:agenda).name
     newcontext.user_id = contexts(:agenda).user_id
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "already exists", newcontext.errors[:name][0]
  end
    
  def test_delete_context_deletes_todos_within_it
    assert_equal 7, @agenda.todos.count
    agenda_todo_ids = @agenda.todos.collect{|t| t.id }
    @agenda.destroy
    agenda_todo_ids.each do |todo_id|
      assert !Todo.exists?(todo_id)
    end
  end
        
  def test_to_param_returns_id
    assert_equal '1', @agenda.to_param
  end
    
  def test_title_reader_returns_name
    assert_equal @agenda.name, @agenda.title
  end

  def test_hidden_attr_reader
    assert !@agenda.hidden?
    @agenda.hide = true
    @agenda.save!
    @agenda.reload
    assert_equal true, @agenda.hidden?
  end

  def test_null_object
    c = Context.null_object
    assert c.nil?
    assert_nil c.id
    assert_equal '', c.name
  end

end
