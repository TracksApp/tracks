require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects, :contexts, :todos, :recurring_todos, :users, :preferences
  
  def setup
    @timemachine = projects(:timemachine)
    @moremoney = projects(:moremoney)
  end
  
  # associations
  
  def test_has_default_context
    assert !@timemachine.default_context.nil?
    assert @timemachine.default_context.name == contexts(:lab).name
    
    p = Project.new
    assert_equal '', p.default_context.name
    p.default_context = contexts(:agenda)
    assert_equal 'agenda', p.default_context.name
  end
  
  # validations
  
  def test_validate_presence_of_name
    @timemachine.name = ""
    assert !@timemachine.save
    assert_equal 1, @timemachine.errors.count
    assert_equal "project must have a name", @timemachine.errors[:name][0]
  end
  
  def test_validate_name_is_less_than_256
    @timemachine.name = generate_random_string(256)
    assert !@timemachine.save
    assert_equal 1, @timemachine.errors.count
    assert_equal "project name must be less than 256 characters", @timemachine.errors[:name][0]
  end
  
  def test_validate_name_is_unique
    newproj = Project.new
    newproj.name = projects(:timemachine).name
    newproj.user_id = projects(:timemachine).user_id
    assert !newproj.save
    assert_equal 1, newproj.errors.count
    assert_equal "already exists", newproj.errors[:name][0]
  end
      
  # state machine
  
  def test_project_initial_state_is_active
    assert_equal :active, @timemachine.aasm_current_state
    assert @timemachine.active?
  end
  
  def test_hide_project
    @timemachine.hide!
    assert_equal :hidden, @timemachine.aasm_current_state
    assert @timemachine.hidden?
  end
  
  def test_activate_project
    @timemachine.activate!
    assert_equal :active, @timemachine.aasm_current_state
    assert @timemachine.active?
  end

  def test_transition_to_another_state
    assert_equal :active, @timemachine.aasm_current_state
    @timemachine.transition_to(:hidden)
    assert_equal :hidden, @timemachine.aasm_current_state
    @timemachine.transition_to(:completed)
    assert_equal :completed, @timemachine.aasm_current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.aasm_current_state
  end

  def test_transition_to_same_state
    assert_equal :active, @timemachine.aasm_current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.aasm_current_state
  end

  # other tests
  
  def test_review_project
    assert_nil @timemachine.last_reviewed
    assert @timemachine.needs_review?(nil)
  end

  def test_review_completedprojects
    @timemachine.complete!
    assert !@timemachine.needs_review?(nil)
  end

  def test_complete_project
    assert_nil @timemachine.completed_at
    @timemachine.complete!
    assert_equal :completed, @timemachine.aasm_current_state
    assert @timemachine.completed?
    assert_not_nil @timemachine.completed_at, "completed_at not expected to be nil"
    assert_in_delta Time.now, @timemachine.completed_at, 1
  end
  
  def test_delete_project_deletes_todos_within_it
    assert_equal 3, @timemachine.todos.count
    timemachine_todo_ids = @timemachine.todos.map{ |t| t.id }
    @timemachine.destroy
    timemachine_todo_ids.each do |t_id|
      assert !Todo.exists?(t_id)
    end
  end
  
  def test_deferred_todos
    assert_equal 1, @timemachine.todos.deferred.size
    t = @timemachine.todos.not_completed[0]
    t.show_from = 1.days.from_now.utc
    t.save!
    assert_equal 2, Project.find(@timemachine.id).todos.deferred.size
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
  
  def test_deferred_todo_count
    assert_equal 1, @timemachine.todos.deferred.count
    assert_equal 0, @moremoney.todos.deferred.count
    
    first_todo = @moremoney.todos[0]
    first_todo.show_from = Time.zone.now + 1.week
    assert_equal :deferred, @moremoney.todos[0].aasm_current_state
    
    assert_equal 1, @moremoney.todos.deferred.count
  end

  def test_done_todo_count
    assert_equal 0, @timemachine.todos.completed.count
    assert_equal 0, @moremoney.todos.completed.count
    @moremoney.todos[0].complete!
    assert_equal 1, @moremoney.todos.completed.count
  end

  def test_not_done_todo_count
    assert_equal 3, @timemachine.todos.not_completed.count
    assert_equal 4, @moremoney.todos.not_completed.count
    @moremoney.todos[0].complete!
    assert_equal 3, @moremoney.todos.not_completed.count
  end

  def test_convert_from_todo
    todo = todos(:upgrade_rails)
    project = Project.create_from_todo(todo)
    assert_equal project.name, todo.description
    assert_equal project.description, todo.notes
    assert_equal project.default_context, todo.context
  end
  
end
