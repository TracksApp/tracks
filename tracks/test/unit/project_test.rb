require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects, :contexts, :todos, :users, :preferences
  
  def setup
    @timemachine = projects(:timemachine)
    @moremoney = projects(:moremoney)
  end
  
  def test_validate_presence_of_name
    @timemachine.name = ""
    assert !@timemachine.save
    assert_equal 1, @timemachine.errors.count
    assert_equal "project must have a name", @timemachine.errors.on(:name)
  end
  
  def test_validate_name_is_less_than_256
    @timemachine.name = "a"*256
    assert !@timemachine.save
    assert_equal 1, @timemachine.errors.count
    assert_equal "project name must be less than 256 characters", @timemachine.errors.on(:name)
  end
  
  def test_validate_name_is_unique
    newproj = Project.new
    newproj.name = projects(:timemachine).name
    newproj.user_id = projects(:timemachine).user_id
    assert !newproj.save
    assert_equal 1, newproj.errors.count
    assert_equal "already exists", newproj.errors.on(:name)
  end
  
  def test_validate_name_does_not_contain_slash
    newproj = Project.new
    newproj.name = "Save Earth/Mankind from Evil"
    assert !newproj.save
    assert_equal 1, newproj.errors.count
    assert_equal "cannot contain the slash ('/') character", newproj.errors.on(:name)
  end
  
  def test_validate_name_does_not_contain_comma
    newproj = Project.new
    newproj.name = "Buy iPhones for Luke,bsag,David Allen"
    assert !newproj.save
    assert_equal 1, newproj.errors.count
    assert_equal "cannot contain the comma (',') character", newproj.errors.on(:name)
  end
  
  def test_project_initial_state_is_active
    assert_equal :active, @timemachine.current_state
    assert @timemachine.active?
  end
  
  def test_hide_project
    @timemachine.hide!
    assert_equal :hidden, @timemachine.current_state
    assert @timemachine.hidden?
  end
  
  def test_activate_project
    @timemachine.activate!
    assert_equal :active, @timemachine.current_state
    assert @timemachine.active?
  end
  
  def test_complete_project
    @timemachine.complete!
    assert_equal :completed, @timemachine.current_state
    assert @timemachine.completed?
  end
  
  def test_find_project_by_namepart_with_exact_match
    p = Project.find_by_namepart('Build a working time machine')
    assert_not_nil p
    assert_equal @timemachine.id, p.id
  end
  
  def test_find_project_by_namepart_with_starts_with
    p = Project.find_by_namepart('Build a')
    assert_not_nil p
    assert_equal @timemachine.id, p.id
  end
  
  def test_delete_project_deletes_todos_within_it
    assert_equal 3, @timemachine.todos.count
    timemachine_todo_ids = @timemachine.todos.map{ |t| t.id }
    @timemachine.destroy
    timemachine_todo_ids.each do |t_id|
      assert !Todo.exists?(t_id)      
    end
  end
  
  def test_not_done_todos
    assert_equal 2, @timemachine.not_done_todos.size
    t = @timemachine.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 1, Project.find(@timemachine.id).not_done_todos.size
  end
  
  def test_done_todos
    assert_equal 0, @timemachine.done_todos.size
    t = @timemachine.not_done_todos[0]
    t.complete!
    t.save!
    assert_equal 1, Project.find(@timemachine.id).done_todos.size
  end
  
  def test_deferred_todos
    assert_equal 1, @timemachine.deferred_todos.size
    t = @timemachine.not_done_todos[0]
    t.show_from = 1.days.from_now.utc.to_date
    t.save!
    assert_equal 2, Project.find(@timemachine.id).deferred_todos.size
  end
  
  def test_url_friendly_name_for_name_with_spaces
    assert_url_friendly_name_converts_properly 'Build a playhouse', 'Build_a_playhouse'
  end
  
  def test_url_friendly_name_for_name_without_spaces
    assert_url_friendly_name_converts_properly 'NoSpacesHere', 'NoSpacesHere'
  end
  
  def test_url_friendly_name_for_name_with_an_underscore
    assert_url_friendly_name_converts_properly 'there is an_underscore', 'there_is_an__underscore'
  end
  
  def test_url_friendly_name_for_name_with_a_dot
    assert_url_friendly_name_converts_properly 'hello.com', 'hello__dot__com'
  end
  
  def assert_url_friendly_name_converts_properly(name, url_friendly_name)
    project = Project.create(:name => name)
    assert_equal url_friendly_name, project.url_friendly_name
    found_project = Project.find_by_url_friendly_name(url_friendly_name)
    assert_not_nil project
    assert_equal project.id, found_project.id
  end
  
  def test_to_param_returns_url_friendly_name
    assert_equal 'Build_a_working_time_machine', @timemachine.to_param
  end
  
  def test_title_reader_returns_name
    assert_equal @timemachine.name, @timemachine.title
  end
  
  def test_created_at_returns_now_when_field_null
    assert_equal Time.now.to_s, @moremoney.created_at.to_s
  end
  
  def test_updated_at_returns_now_when_field_null
    assert_equal Time.now.to_s, @moremoney.updated_at.to_s
  end
  
end
