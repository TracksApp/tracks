require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TodoTest < ActiveSupport::TestCase
  fixtures :todos, :recurring_todos, :users, :contexts, :preferences, :tags, :taggings, :projects

  def setup
    @not_completed1 = Todo.find(1).reload
    @not_completed2 = Todo.find(2).reload
    @completed = Todo.find(8).reload
  end

  # Test loading a todo item
  def test_load
    assert_kind_of Todo, @not_completed1
    assert_equal 1, @not_completed1.id
    assert_equal 1, @not_completed1.context_id
    assert_equal 2, @not_completed1.project_id
    assert_equal "Call Bill Gates to find out how much he makes per day", @not_completed1.description
    assert_nil @not_completed1.notes
    assert @not_completed1.completed? == false
    assert_equal 1.week.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M"), @not_completed1.created_at.strftime("%Y-%m-%d %H:%M")
    assert_equal 2.week.from_now.beginning_of_day.strftime("%Y-%m-%d"), @not_completed1.due.strftime("%Y-%m-%d")
    assert_nil @not_completed1.completed_at
    assert_equal 1, @not_completed1.user_id
  end

  def test_completed
    assert_kind_of Todo, @completed
    assert @completed.completed?
    assert_not_nil @completed.completed_at
  end

  def test_completed_at_cleared_after_toggle_to_active
    assert_kind_of Todo, @completed
    assert @completed.completed?
    @completed.toggle_completion!
    assert @completed.active?
    assert_nil @completed.completed_at
  end


  # Validation tests
  #
  def test_validate_presence_of_description
    assert_equal "Call dinosaur exterminator", @not_completed2.description
    @not_completed2.description = ""
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "can't be blank", @not_completed2.errors[:description][0]
  end

  def test_validate_length_of_description
    assert_equal "Call dinosaur exterminator", @not_completed2.description
    @not_completed2.description = generate_random_string(101)
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "is too long (maximum is 100 characters)", @not_completed2.errors[:description][0]
  end

  def test_validate_length_of_notes
    assert_equal "Ask him if I need to hire a skip for the corpses.", @not_completed2.notes
    @not_completed2.notes = generate_random_string(60001)
    assert !@not_completed2.save
    assert_equal 1, @not_completed2.errors.count
    assert_equal "is too long (maximum is 60000 characters)", @not_completed2.errors[:notes][0]
  end

  def test_validate_show_from_must_be_a_date_in_the_future
    t = @not_completed2
    t.show_from = 1.week.ago
    
    assert !t.save, "todo should not be saved without validation errors"
    assert_equal 1, t.errors.count
    assert_equal "must be a date in the future", t.errors[:show_from][0]
  end
  
  def test_validate_circular_dependencies
    @completed.activate!
    @not_completed3=@completed
    
    # 2 -> 1
    @not_completed1.add_predecessor(@not_completed2)
    assert @not_completed1.save!
    assert_equal 1, @not_completed2.successors.count
    
    # 3 -> 2 -> 1
    @not_completed2.add_predecessor(@not_completed3)
    assert @not_completed2.save!
    assert_equal 1, @not_completed3.successors.count
    
    # 1 -> 3 -> 2 -> 1 == circle
    @not_completed3.add_predecessor(@not_completed1)
    assert !@not_completed3.valid?
    error_msg = "Adding ''Call Bill Gates to find out how much he makes per day' <'agenda'; 'Make more money than Billy Gates'>' would create a circular dependency"
    assert_equal error_msg, @not_completed3.errors["Depends on:"][0]
  end

  def test_defer_an_existing_todo
    @not_completed2
    assert_equal :active, @not_completed2.aasm_current_state
    @not_completed2.show_from = Time.zone.now + 1.week
    assert @not_completed2.save, "should have saved successfully" + @not_completed2.errors.to_xml
    assert_equal :deferred, @not_completed2.aasm_current_state
  end

  def test_create_a_new_deferred_todo
    user = users(:other_user)
    todo = user.todos.build
    todo.show_from = next_week
    todo.context_id = 1
    todo.description = 'foo'
    assert todo.save, "should have saved successfully" + todo.errors.to_xml
    assert_equal :deferred, todo.aasm_current_state
  end

  def test_create_a_new_deferred_todo_by_passing_attributes
    user = users(:other_user)
    todo = user.todos.build(:show_from => next_week, :context_id => 1, :description => 'foo')
    assert todo.save, "should have saved successfully" + todo.errors.to_xml
    assert_equal :deferred, todo.aasm_current_state
  end

  def test_toggle_completion
    t = @not_completed1
    assert_equal :active, t.aasm_current_state
    t.toggle_completion!
    assert_equal :completed, t.aasm_current_state
    t.toggle_completion!
    assert_equal :active, t.aasm_current_state
  end
  
  def test_toggle_completion_with_show_from_in_future
    t = @not_completed1
    t.show_from= 1.week.from_now
    t.save!
    assert_equal :deferred, t.aasm_current_state
    t.toggle_completion!
    assert_equal :completed, t.aasm_current_state
  end
  
  def test_toggle_completion_with_show_from_in_past
    t = @not_completed1
    t.update_attribute(:show_from, 1.week.ago)
    assert_equal :active, t.aasm_current_state
    
    assert t.toggle_completion!, "shoud be able to mark active todo complete even if show_from is set in the past"
    assert_equal :completed, t.aasm_current_state
  end

  def test_activate_also_saves
    t = @not_completed1
    t.show_from = 1.week.from_now
    t.save!
    assert t.deferred?
    t.reload
    t.activate!
    assert t.active?
    t.reload
    assert t.active?
  end

  def test_activate_also_clears_show_from
    # setup test case
    t = @not_completed1
    t.show_from = 1.week.from_now
    t.save!
    assert t.deferred?
    t.reload

    # activate and check show_from
    t.activate!
    assert t.active?
    assert t.show_from.nil?
  end

  def test_project_returns_null_object_when_nil
    t = @not_completed1
    assert !t.project.is_a?(NullProject)
    t.project = nil
    assert t.project.is_a?(NullProject)
  end

  def test_initial_state_defaults_to_active
    t = Todo.new
    t.description = 'foo'
    t.context_id = 1
    t.save!
    t.reload
    assert_equal :active, t.aasm_current_state
  end

  def test_initial_state_is_deferred_when_show_from_in_future
    t = Todo.new
    t.user = users(:admin_user)
    t.description = 'foo'
    t.context_id = 1
    t.show_from = 1.week.from_now.to_date
    t.save!
    t.reload
    assert_equal :deferred, t.aasm_current_state
  end

  def test_todo_is_not_starred
    assert !@not_completed1.starred?
  end

  def test_todo_2_is_not_starred
    assert !Todo.find(2).starred?
  end

  def test_todo_is_starred_after_starred_tag_is_added
    @not_completed1._add_tags('starred')
    assert @not_completed1.starred?
  end

  def test_todo_is_starred_after_toggle_starred
    @not_completed1.toggle_star!
    assert @not_completed1.starred?
  end

  def test_todo_is_not_starred_after_toggle_starred_twice
    @not_completed1.toggle_star!
    @not_completed1.toggle_star!
    assert !@not_completed1.starred?
  end

  def test_todo_specification_handles_null_project
    # @not_completed1 has a project
    todo_desc = @not_completed1.description
    assert_equal "'#{todo_desc}' <'agenda'; 'Make more money than Billy Gates'>", @not_completed1.specification

    # now check on null
    @not_completed1.project = nil
    @not_completed1.save
    assert_equal "'#{todo_desc}' <'agenda'; '(none)'>", @not_completed1.specification
  end

  def test_add_predecessor_list
    todo = Todo.new

    single = @not_completed1.id.to_s
    multi = single + ", " + @not_completed2.id.to_s # note one space after comma

    @predecessor_array = todo.add_predecessor_list(single)
    assert_not_nil @predecessor_array
    assert_equal 1, @predecessor_array.size

    @predecessor_array = todo.add_predecessor_list(multi)
    assert_not_nil @predecessor_array
    assert_equal 2, @predecessor_array.size
  end

  def test_add_predecessor_list_with_comma
    # test for #975
    todo = Todo.new

    @not_completed1.description = "test,1,2,3"
    @not_completed1.save
    @not_completed2.description = "test,4,5,6"
    @not_completed2.save

    single = @not_completed1.id.to_s
    multi = single + "," + @not_completed2.id.to_s  # note no space after comma

    @predecessor_array = todo.add_predecessor_list(single)
    assert_not_nil @predecessor_array
    assert_equal 1, @predecessor_array.size

    @predecessor_array = todo.add_predecessor_list(multi)
    assert_not_nil @predecessor_array
    assert_equal 2, @predecessor_array.size
  end

  def test_finding_todos_with_a_tag
    todo = @not_completed1
    todo.tag_list = "a, b, c"
    todo.save!

    tag_a = Tag.find_by_name("a")
    tag_b = Tag.find_by_name("b")
    tag_c = Tag.find_by_name("c")

    todos_with_a = Todo.with_tag(tag_a)
    assert_equal 1, todos_with_a.count
    assert_equal todo.description, todos_with_a.first.description

    todos_with_b = Todo.with_tag(tag_b)
    assert_equal 1, todos_with_b.count
    assert_equal todo.id, todos_with_b.first.id

    todo2 = @not_completed2
    todo2.tag_list = "a, c, d"
    todo2.save!

    tag_d = Tag.find_by_name("d")

    todos_with_a = Todo.with_tag(tag_a)
    assert_equal 2, todos_with_a.count

    todos_with_d = Todo.with_tag(tag_d)
    assert_equal 1, todos_with_d.count
  end

  def test_finding_todos_with_more_tags_using_OR
    todo1 = @not_completed1
    todo1.tag_list = "a, b, c"
    todo1.save!

    todo2 = @not_completed2
    todo2.tag_list = "a, c, d"
    todo2.save!

    tag_a = Tag.find_by_name("a")
    tag_b = Tag.find_by_name("b")
    tag_c = Tag.find_by_name("c")
    tag_d = Tag.find_by_name("d")

    # overlapping tags
    tag_ids = [tag_a.id, tag_c.id]
    todos_with_a_or_c = Todo.with_tags(tag_ids)
    assert_equal 2, todos_with_a_or_c.count

    # non-overlapping tags
    tag_ids = [tag_b.id, tag_d.id]
    todos_with_b_or_d = Todo.with_tags(tag_ids)
    assert_equal 2, todos_with_b_or_d.count
  end

  def test_finding_todos_with_more_tags_using_AND
    todo1 = @not_completed1
    todo1.tag_list = "a, b, c"
    todo1.save!

    todo2 = @not_completed2
    todo2.tag_list = "a, c, d"
    todo2.save!

    tag_a_id = Tag.find_by_name("a").id
    tag_b_id = Tag.find_by_name("b").id

    todos_with_a_and_b = Todo.with_tags([tag_a_id]).with_tags([tag_b_id])
    assert_equal 1, todos_with_a_and_b.count
    assert_equal todo1.id, todos_with_a_and_b.first.id
  end

  def test_finding_todos_with_more_tags_using_AND_and_OR
    todo1 = @not_completed1
    todo1.tag_list = "a, b, c"
    todo1.save!

    todo2 = @not_completed2
    todo2.tag_list = "a, c, d"
    todo2.save!

    tag_a_id = Tag.find_by_name("a").id
    tag_b_id = Tag.find_by_name("b").id
    tag_c_id = Tag.find_by_name("c").id

    todos_with_aORc_and_b = Todo.with_tags([tag_a_id, tag_c_id]).with_tags([tag_b_id])
    assert_equal 1, todos_with_aORc_and_b.count
    assert_equal todo1.id, todos_with_aORc_and_b.first.id

    # let todo2 fit the expression
    todo2.tag_list = "a, b, r"
    todo2.save!
    todos_with_aORc_and_b = Todo.with_tags([tag_a_id, tag_c_id]).with_tags([tag_b_id])
    assert_equal 2, todos_with_aORc_and_b.count
  end

  # test named_scopes
  def test_find_completed
    # Given 2 completed todos, one completed now and one completed 2 months ago
    @not_completed1.toggle_completion!
    @completed.completed_at = 2.months.ago
    @completed.save!

    completed_old = @completed
    completed_now = @not_completed1

    # When I use the finders
    recent_completed_todos = Todo.completed_after(1.month.ago).find(:all)
    older_completed_todos = Todo.completed_before(1.month.ago).find(:all)

    # Then completed1 should be before and completed2 should be after a month ago
    assert older_completed_todos.include?(completed_old)
    assert recent_completed_todos.include?(completed_now)

    # And completed1 should not be after and completed2 should not be before a month ago
    assert !older_completed_todos.include?(completed_now)
    assert !recent_completed_todos.include?(completed_old)
  end

  def test_find_created
    # Given 2 created todos, one created now and one created 2 months ago
    user = @completed.user
    todo_old = user.todos.create!({:description => "created long long ago", :context => @completed.context})
    todo_old.created_at = 2.months.ago
    todo_old.save!
    todo_now = user.todos.create!({:description => "just created", :context => @completed.context})

    # When I use the finders
    recent_created_todos = Todo.created_after(1.month.ago).find(:all)
    older_created_todos = Todo.created_before(1.month.ago).find(:all)

    # Then todo1 should be before and todo2 should be after a month ago
    assert older_created_todos.include?(todo_old)
    assert recent_created_todos.include?(todo_now)

    # And todo1 should not be after and todo2 should not be before a month ago
    assert !older_created_todos.include?(todo_now)
    assert !recent_created_todos.include?(todo_old)
  end
  
  def test_notes_are_rendered_on_save
    user = @completed.user
    todo = user.todos.create(:description => "test", :context => @completed.context)
    
    assert_nil todo.notes
    assert_nil todo.rendered_notes
    
    todo.notes = "*test*"
    todo.save!
    todo.reload
    
    assert_equal "*test*", todo.notes
    assert_equal "<p><strong>test</strong></p>", todo.rendered_notes
  end
  
end
