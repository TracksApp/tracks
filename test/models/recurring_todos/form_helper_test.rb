require_relative '../../test_helper'

module RecurringTodos

  class AttributeHandlerTest < ActiveSupport::TestCase
    fixtures :users

    def test_method_missing
      rt = users(:admin_user).recurring_todos.first
      rt.every_other1 = 42
      rt.every_day = 'smtwtfs'
      rt.save

      h = FormHelper.new(rt)

      assert_equal 42,  h.daily_every_x_days,  "should be passed to DailyRepeatPattern"
      assert_equal 42,  h.weekly_every_x_week, "should be passed to WeeklyRepeatPattern"
      assert_equal 42,  h.monthly_every_x_day, "should be passed to MonthlyRepeatPattern"
      assert_equal 42,  h.yearly_every_x_day,  "should be passed to YearlyRepeatPattern"
      assert            h.on_monday,           "should be passed to WeeklyRepeatPattern"
    end
  end

end