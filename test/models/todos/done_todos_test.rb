require 'test_helper'

module Todos
  class DoneTodosTest < ActiveSupport::TestCase

    def test_completed_period
      travel_to Time.zone.local(2013,1,23,12,00,00) do  # wednesday at 12:00;
        assert_equal "today",         DoneTodos.completed_period(Time.zone.local(2013,1,23,9,00))   # today at 9:00
        assert_equal "rest_of_week",  DoneTodos.completed_period(Time.zone.local(2013,1,21))        # monday this week
        assert_equal "rest_of_month", DoneTodos.completed_period(Time.zone.local(2013,1,8))         # tuestday in first week of jan 

        assert_nil DoneTodos.completed_period(nil)
        assert_nil DoneTodos.completed_period(Time.zone.local(2012,12,1))                           # older than this month

        assert_equal "today", DoneTodos.completed_period(Time.zone.local(2013,12,1))                # date in future -> act as if today
      end
    end

    def test_done_today
      todos = users(:admin_user).todos
      assert 0, DoneTodos.done_today(todos, {}).count

      t = users(:admin_user).todos.active.first
      t.complete!

      assert 0, DoneTodos.done_today(todos.reload, {}).count      
    end

    def test_done_rest_of_week
      todos = users(:admin_user).todos

      # When I mark a todo complete on jan 1
      travel_to Time.zone.local(2013,1,1,0,0) do
        t = users(:admin_user).todos.active.first
        t.complete!
      end

      # Then I should be in rest_of_week on jan 2
      travel_to Time.zone.local(2013,1,2,0,0) do
        assert 0, DoneTodos.done_today(todos.reload, {}).count
        assert 1, DoneTodos.done_rest_of_week(todos.reload, {}).count
      end
    end

    def test_done_rest_of_month
      todos = users(:admin_user).todos

      # When I mark a todo complete on jan 1
      travel_to Time.zone.local(2013,1,1,0,0) do
        t = users(:admin_user).todos.active.first
        t.complete!
      end

      # Then I should be in rest_of_month on jan 21
      travel_to Time.zone.local(2013,1,21,0,0) do
        assert 0, DoneTodos.done_today(todos.reload, {}).count
        assert 0, DoneTodos.done_rest_of_week(todos.reload, {}).count
        assert 1, DoneTodos.done_rest_of_month(todos.reload, {}).count
      end
    end


  end
end
