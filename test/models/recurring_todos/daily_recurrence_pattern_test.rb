require 'test_helper'

module RecurringTodos

  class DailyRecurrencePatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      super
      @admin = users(:admin_user)
      @every_day = recurring_todos(:call_bill_gates_every_day)
      @every_workday = recurring_todos(:call_bill_gates_every_workday)
    end

    def test_daily_attributes
      rt = @admin.recurring_todos.first

      assert_equal rt.every_other1, rt.pattern.every_x_days
      assert_equal rt.only_work_days, rt.pattern.only_work_days?
    end

    def test_validate
      rt = @admin.recurring_todos.first
      assert rt.valid?, "rt should be valid at start"

      rt.every_other1 = nil
      rt.only_work_days = false
      assert !rt.valid?, "every_x_days should not be empty then only_work_days==false"

      rt.only_work_days = true
      assert rt.valid?, "every_x_days may have any value for only_work_days==true"

      rt.only_work_days = false
      rt.every_other1 = 2
      assert rt.valid?, "should be valid again"
    end

    def test_pattern_text
      @every_day = recurring_todos(:call_bill_gates_every_day)
      @every_workday = recurring_todos(:call_bill_gates_every_workday)

      assert_equal "every day", @every_day.recurrence_pattern
      assert_equal "on work days", @every_workday.recurrence_pattern
      
      @every_day.every_other1 = 2
      assert_equal "every 2 days", @every_day.recurrence_pattern      
    end

    def test_daily_every_day
      # every_day should return todays date if there was no previous date
      due_date = @every_day.get_due_date(nil)
      # use only day-month-year compare, because milisec / secs could be different
      assert_equal_dmy @today, due_date

      # when the last todo was completed today, the next todo is due tomorrow
      due_date = @every_day.get_due_date(@today)
      assert_equal @tomorrow, due_date

      # do something every 14 days
      @every_day.every_other1=14
      due_date = @every_day.get_due_date(@today)
      assert_equal @today+14.days, due_date
    end

    def test_only_work_days_skips_weekend
      assert_equal @tuesday, @every_workday.get_due_date(@monday), "should select next day if it is not in weekend"

      assert_equal @monday,  @every_workday.get_due_date(@friday), "should select monday if it is in weekend"
      assert_equal @monday,  @every_workday.get_due_date(@saturday), "should select monday if it is in weekend"
      assert_equal @monday,  @every_workday.get_due_date(@sunday), "should select monday if it is in weekend"
    end

    def test_every_x_days
      assert_equal @tuesday,  @every_day.get_due_date(@monday), "should select next day in middle week"
      assert_equal @saturday, @every_day.get_due_date(@friday), "should select next day at end of week"
      assert_equal @sunday,   @every_day.get_due_date(@saturday), "should select next day in weekend"
    end

  end

end