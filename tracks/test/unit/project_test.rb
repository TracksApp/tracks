require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects

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

end
