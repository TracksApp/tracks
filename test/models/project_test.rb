require 'test_helper'

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
    assert_equal :active, @timemachine.aasm.current_state
    assert @timemachine.active?
  end

  def test_hide_project
    @timemachine.hide!
    assert_equal :hidden, @timemachine.aasm.current_state
    assert @timemachine.hidden?
  end

  def test_activate_project
    @timemachine.activate!
    assert_equal :active, @timemachine.aasm.current_state
    assert @timemachine.active?
  end

  def test_transition_to_another_state
    assert_equal :active, @timemachine.aasm.current_state
    @timemachine.transition_to(:hidden)
    assert_equal :hidden, @timemachine.aasm.current_state
    @timemachine.transition_to(:completed)
    assert_equal :completed, @timemachine.aasm.current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.aasm.current_state
  end

  def test_transition_to_same_state
    assert_equal :active, @timemachine.aasm.current_state
    @timemachine.transition_to(:active)
    assert_equal :active, @timemachine.aasm.current_state
  end

  # other tests

  def test_review_project
    assert_nil @timemachine.last_reviewed
    assert @timemachine.needs_review?(users(:admin_user))
  end

  def test_review_completedprojects
    @timemachine.complete!
    refute @timemachine.needs_review?(users(:admin_user))
  end

  def test_new_project_is_reviewed
    project = users(:admin_user).projects.create!(:name => "test1")
    refute project.needs_review?(users(:admin_user))
  end

  def test_complete_project
    assert_nil @timemachine.completed_at
    @timemachine.complete!
    assert_equal :completed, @timemachine.aasm.current_state
    assert @timemachine.completed?
    assert_not_nil @timemachine.completed_at, "completed_at not expected to be nil"
    assert_in_delta Time.zone.now, @timemachine.completed_at, 1
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
    assert_equal "", p.name
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
    first_todo.save!
    assert_equal :deferred, @moremoney.todos[0].aasm.current_state

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

  def test_new_record_before_save
    assert !@timemachine.new_record_before_save?, "existing records should not be new_record"
    p = Project.where(:name => "I do not exist").first_or_create
    assert p.new_record_before_save?, "newly created record should be new_record"
  end

  def test_shortened_name
    s = "project"*7 # len=49
    p = users(:admin_user).projects.create(:name => s)
    assert_equal 49, p.name.length
    assert_equal 40, p.shortened_name.length
    assert_equal "project"*5+"pr...", p.shortened_name

    assert p.shortened_name.html_safe?
  end

  def test_note_count
    p = users(:admin_user).projects.first
    assert_not_nil p

    assert_equal 2, p.note_count

    p.notes.create(:user_id => p.user_id, :body => "new note")

    assert_equal 3, p.note_count
  end

  def test_project_blocked
    p = users(:admin_user).projects.first

    assert !p.blocked?, "first project should not be blocked"

    p.complete!
    assert !p.blocked?, "completed projects should not be blocked"

    p.activate!
    p.todos.each{|t| t.show_from = 2.weeks.from_now; t.save! }
    assert p.blocked?, "projects with deferred todos should be blocked"

    p.todos.first.complete!
    assert p.blocked?, "projects with deferred todo should be blocked even if a completed todo exists"
  end

  def test_project_stalled
    p = users(:admin_user).projects.first

    p.hide!
    assert !p.stalled?, "hidden projects are not stalled"

    p.complete!
    assert !p.stalled?, "completed projects are not stalled"

    p.activate!
    p.todos.each(&:complete!)
    assert p.todos.reload.active.empty?, "project should not have active todos"
    assert p.todos.reload.deferred_or_blocked.empty?, "there should not be deferred or blocked todos"
    assert p.reload.stalled?, "project should be stalled"
  end

  def test_age_in_days
    p1 = users(:admin_user).projects.create!(:name => "test1")
    assert_equal 1, p1.age_in_days, "newly created project has age or one day"

    p2 = users(:admin_user).projects.create!(:name => "test7")
    p2.created_at = 1.week.ago
    p2.save!

    p2.reload
    assert_equal 8, p2.age_in_days
  end

  def test_running_time
    p = users(:admin_user).projects.create!(:name => "test8")
    p.created_at = 1.week.ago
    p.save!

    p.reload
    assert_equal 8, p.running_time

    p.completed_at = 4.days.ago
    p.save!

    p.reload
    assert_equal 4, p.running_time
  end
end
