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
    newproj.name = "Build a working time machine"
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

end
