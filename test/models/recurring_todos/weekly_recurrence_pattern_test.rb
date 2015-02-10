require 'test_helper'

module RecurringTodos

  class WeeklyRecurrencePatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      super
      @admin = users(:admin_user)
    end 

    def test_every_x_week
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first

      assert_equal rt.every_other1, rt.pattern.every_x_week
    end

    def test_on_xday
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert rt.valid?, "should be valid at start: id= #{rt.id} --> #{rt.errors.full_messages}"

      rt.every_day = 'smtwtfs'
      %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
        assert rt.pattern.send("on_#{day}"), "on_#{day} should return true"
      end

      rt.every_day = 'smt tfs' # no wednesday
      assert !rt.pattern.on_wednesday, "wednesday should be false"
    end

    def test_validations
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert rt.valid?, "should be valid at start: #{rt.errors.full_messages}"

      rt.every_other1 = nil
      assert !rt.valid?, "missing evert_x_week should not be valid"

      rt.every_other1 = 1
      rt.every_day = '       '
      assert !rt.valid?, "missing selected days in every_day"
    end
    
    def test_pattern_text
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert_equal "every 2 weeks", rt.recurrence_pattern            

      rt.every_other1 = 1
      assert_equal "weekly", rt.recurrence_pattern            
    end

    def test_weekly_pattern
      rt = recurring_todos(:call_bill_gates_every_week)
      due_date = rt.get_due_date(@sunday)
      assert_equal @monday, due_date

      # saturday is last day in week, so the next date should be sunday + n-1 weeks
      # n-1 because sunday is already in the next week
      rt.every_other1 = 3
      due_date = rt.get_due_date(@saturday)
      assert_equal @sunday + 2.weeks, due_date

      # remove tuesday and wednesday
      rt.every_day = 'sm  tfs'
      due_date = rt.get_due_date(@monday)
      assert_equal @thursday, due_date

      rt.every_other1 = 1
      rt.every_day = '  tw   '
      due_date = rt.get_due_date(@tuesday)
      assert_equal @wednesday, due_date
      due_date = rt.get_due_date(@wednesday)
      assert_equal @tuesday+1.week, due_date

      rt.every_day = '      s'
      due_date = rt.get_due_date(@sunday)
      assert_equal @saturday+1.week, due_date
    end

  end

end