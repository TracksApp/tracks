require File.dirname(__FILE__) + '/../test_helper'

class ContextTest < Test::Unit::TestCase
  fixtures :contexts, :todos, :users, :preferences

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
  
  def test_validate_name_does_not_contain_slash
     newcontext = Context.new
     newcontext.name = "phone/telegraph"
     assert !newcontext.save
     assert_equal 1, newcontext.errors.count
     assert_equal "cannot contain the slash ('/') character", newcontext.errors.on(:name)
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
    assert_equal 6, @agenda.todos.count
    agenda_todo_ids = @agenda.todos.collect{|t| t.id }
    @agenda.destroy
    agenda_todo_ids.each do |todo_id|
      assert !Todo.exists?(todo_id)
    end
  end
  
  def test_not_done_todos
    assert_equal 5, @agenda.not_done_todos.size
    t = @agenda.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 4, Context.find(@agenda.id).not_done_todos.size
  end
    
  def test_done_todos
    assert_equal 1, @agenda.done_todos.size
    t = @agenda.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 2, Context.find(@agenda.id).done_todos.size
  end
  
  def test_url_friendly_name_for_name_with_spaces
    assert_url_friendly_name_converts_properly 'any computer', 'any_computer'
  end
  
  def test_url_friendly_name_for_name_without_spaces
    assert_url_friendly_name_converts_properly 'NoSpacesHere', 'NoSpacesHere'
  end
  
  def test_url_friendly_name_for_name_with_underscores
    assert_url_friendly_name_converts_properly 'there is an_underscore', 'there_is_an__underscore'
  end
  
  def assert_url_friendly_name_converts_properly(name, url_friendly_name)
    context = Context.create(:name => name)
    assert_equal url_friendly_name, context.url_friendly_name
    found_context = Context.find_by_url_friendly_name(url_friendly_name)
    assert_not_nil context
    assert_equal context.id, found_context.id
  end
  
  def test_to_param_returns_url_friendly_name
    assert_equal 'agenda', @agenda.to_param
  end
    
  def test_title_reader_returns_name
    assert_equal @agenda.name, @agenda.title
  end
  
  def test_created_at_returns_now_when_field_null
    assert_equal Time.now.utc.to_s, @library.created_at.to_s
  end
  
  def test_updated_at_returns_now_when_field_null
    assert_equal Time.now.utc.to_s, @library.updated_at.to_s
  end
  
end
