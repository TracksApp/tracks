require_relative '../test_helper'

class CalendarControllerTest < ActionController::TestCase
  def test_show
    login_as(:admin_user)

    get :show

    projects = [projects(:timemachine),
                projects(:moremoney),
                projects(:gardenclean)]
    due_today = [todos(:phone_grandfather),
                 todos(:call_bill_gates_every_day),
                 todos(:due_today)]
    due_next_week = [todos(:buy_shares),
                     todos(:buy_stego_bait),
                     todos(:new_action_in_context)]
    due_this_month = [todos(:call_bill),
                      todos(:call_dino_ext)]

    assert_equal "calendar", assigns['source_view']
    assert_equal projects, assigns['projects']
    assert_equal due_today, assigns['calendar'].due_today
    assert_equal [], assigns['calendar'].due_this_week
    assert_equal due_next_week, assigns['calendar'].due_next_week
    assert_equal due_this_month, assigns['calendar'].due_this_month
    assert_equal [], assigns['calendar'].due_after_this_month
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
