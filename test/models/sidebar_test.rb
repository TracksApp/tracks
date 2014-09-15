require 'test_helper'

class SidebarTest < ActiveSupport::TestCase

  def setup
    @sidebar = Sidebar.new(users(:admin_user))
  end

  def test_it_gets_the_active_contexts
    assert @sidebar.active_contexts == users(:admin_user).contexts.active
  end

  def test_it_gets_the_hidden_contexts
    assert @sidebar.hidden_contexts == users(:admin_user).contexts.hidden
  end

  def test_it_gets_the_active_projects
    assert @sidebar.active_projects == users(:admin_user).projects.active
  end

  def test_it_gets_the_hidden_projects
    assert @sidebar.hidden_projects == users(:admin_user).projects.hidden
  end

  def test_it_gets_the_completed_projects
    assert @sidebar.completed_projects == users(:admin_user).projects.completed
  end

end
