require_relative '../../test_helper'

module Todos
  class CalendarTest < ActiveSupport::TestCase

    def setup
      @calendar = Calendar.new(users(:admin_user))
      Todo.destroy_all
    end

    def create_todo(due_date)
      Todo.create due: due_date,
        user: users(:admin_user),
        description: 'Test Todo',
        context: Context.first
    end

    def test_due_today
      due_today = create_todo(Time.zone.now)

      assert_equal [due_today], @calendar.due_today
    end

    def test_due_this_week
      due_this_week = create_todo(Time.zone.now.end_of_week)
      assert_equal [due_this_week], @calendar.due_this_week
    end

    def test_due_next_week
      due_next_week = create_todo(1.week.from_now.beginning_of_day)

      assert_equal [due_next_week], @calendar.due_next_week
    end

    def test_due_this_month
      due_this_month = create_todo(Time.zone.now.end_of_month)

      assert_equal [due_this_month], @calendar.due_this_month
    end

    def test_due_after_this_month
      due_after_this_month = create_todo(1.month.from_now)
      assert_equal [due_after_this_month], @calendar.due_after_this_month
    end
  end
end

