require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
    
  def test_show
    login_as(:admin_user)

    get :show

    projects = [projects(:timemachine),
                projects(:moremoney),
                projects(:gardenclean)]

    assert_equal "calendar", assigns['source_view']
    assert_equal projects, assigns['projects']
    assert_equal 8, assigns['count']
  end

  def test_show_ics
    login_as(:admin_user)
    get :show, :format => 'ics'
    assert_equal 8, assigns['due_all'].count
  end

  def test_show_xml
    login_as(:admin_user)
    get :show, :format => 'xml'
    assert_equal 8, assigns['due_all'].count
  end
end
