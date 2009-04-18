require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Rails::TestCase
  fixtures :projects, :contexts, :todos, :recurring_todos, :users, :preferences
  
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
    
  def test_validate_name_does_not_contain_comma
    newproj = Project.new
    newproj.name = "Buy iPhones for Luke,bsag,David Allen"
    assert !newproj.save
    assert_equal 1, newproj.errors.count
    assert_equal "cannot contain the comma (',') character", newproj.errors.on(:name)
  end
  
  def test_name_removes_extra_spaces
    newproj = Project.new
    newproj.name = "These   Words    Have   Proximity        Issues   "
    assert newproj.save
    assert_equal 0, newproj.errors.count
    assert_equal "These Words Have Proximity Issues", newproj.name
    
    # and on update...
    @timemachine.name = "   a     time machine    needs lots   of      spaaaaaaace         "
    assert @timemachine.save
    assert_equal "a time machine needs lots of spaaaaaaace", @timemachine.name
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
    assert_nil @timemachine.completed_at
    @timemachine.complete!
    assert_equal :completed, @timemachine.current_state
    assert @timemachine.completed?
    assert_not_nil @timemachine.completed_at, "completed_at not expected to be nil"
    assert_in_delta Time.now, @timemachine.completed_at, 1
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
    t.show_from = 1.days.from_now.utc
    t.save!
    assert_equal 2, Project.find(@timemachine.id).deferred_todos.size
  end
    
  def test_to_param_returns_id
    assert_equal '1', @timemachine.to_param
  end

  def test_null_object
    p = Project.null_object
    assert !p.hidden?
    assert p.nil?
    assert_nil p.id
  end

  def test_feed_options
    opts = Project.feed_options(users(:admin_user))
    assert_equal 'Tracks Projects', opts[:title], 'Unexpected value for :title key of feed_options'
    assert_equal 'Lists all the projects for Admin Schmadmin', opts[:description], 'Unexpected value for :description key of feed_options'
  end

  def test_transition_to_another_state
    assert_equal :active, @timemachine.current_state
    @timemachine.transition_to(:hidden)
    assert_equal :hidden, @timemachine.current_state
    @timemachine.transition_to(:completed)
    assert_equal :completed, @timemachine.current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.current_state
  end

  def test_transition_to_same_state
    assert_equal :active, @timemachine.current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.current_state
  end

  def test_deferred_todo_count
    assert_equal 1, @timemachine.deferred_todos.count
    assert_equal 0, @moremoney.deferred_todos.count
    @moremoney.todos[0].show_from = next_week
    assert_equal 1, @moremoney.deferred_todos.count
  end

  def test_done_todo_count
    assert_equal 0, @timemachine.done_todos.count
    assert_equal 0, @moremoney.done_todos.count
    @moremoney.todos[0].complete!
    assert_equal 1, @moremoney.done_todos.count
  end

  def test_not_done_todo_count
    assert_equal 2, @timemachine.not_done_todos.count
    assert_equal 4, @moremoney.not_done_todos.count
    @moremoney.todos[0].complete!
    assert_equal 3, @moremoney.not_done_todos.count
  end
  
  def test_default_context_name
    p = Project.new
    assert_equal '', p.default_context.name
    p.default_context = contexts(:agenda)
    assert_equal 'agenda', p.default_context.name    
  end

end
