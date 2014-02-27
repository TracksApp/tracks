require_relative '../../test_helper'

module RecurringTodos

  class MonthlyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end

    def test_attribute_mapping
      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',    # generic
        'recurring_period'       => 'monthly', 
        'recurring_target'       => 'show_from_date',
        'ends_on'                => 'ends_on_end_date',
        'end_date'               => Time.zone.now + 1.week,
        'start_from'             => Time.zone.now,
        'context_name'           => @admin.contexts.first.name,
        'monthly_selector'       => 'monthly_every_x_day',
        'monthly_every_xth_day'  => 1,
        'monthly_day_of_week'    => 2,
        'monthly_every_x_month'  => 3
      })

      assert builder.save, "should save: #{builder.errors.full_messages}"
      rt = builder.saved_recurring_todo

      assert builder.pattern.is_a?(MonthlyRepeatPattern), "should be monthly pattern, but is #{builder.pattern.class}"
      assert builder.pattern.every_x_day?, "should be true for monthly_every_x_day"
      assert 1, rt.recurrence_selector

      assert_equal 1, builder.pattern.every_xth_day, "pattern should map every_other2 to every_xth_day from monthly_every_xth_day"
      assert_equal 1, rt.every_other3

      assert_equal 2, builder.pattern.day_of_week, "pattern should map every_count to day_of_week from monthly_day_of_week"
      assert_equal 2, rt.every_count
    end

    def test_every_x_month
      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',    # generic
        'recurring_period'       => 'monthly', 
        'recurring_target'       => 'show_from_date',
        'ends_on'                => 'ends_on_end_date',
        'end_date'               => Time.zone.now + 1.week,
        'start_from'             => Time.zone.now,
        'context_name'           => @admin.contexts.first.name,
        'monthly_selector'       => 'monthly_every_x_day',
        'monthly_every_x_month'  => 3,
        'monthly_every_x_month2' => 2
      })

      assert builder.save, "should save: #{builder.errors.full_messages}"
      rt = builder.saved_recurring_todo

      assert_equal 3, builder.pattern.every_x_month
      assert_equal 3, rt.every_other2

      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',    # generic
        'recurring_period'       => 'monthly', 
        'recurring_target'       => 'show_from_date',
        'ends_on'                => 'ends_on_end_date',
        'end_date'               => Time.zone.now + 1.week,
        'start_from'             => Time.zone.now,
        'context_name'           => @admin.contexts.first.name,
        'monthly_selector'       => 'monthly_every_xth_day',
        'monthly_every_x_month'  => 3,
        'monthly_every_x_month2' => 2,
        'monthly_day_of_week'    => 7
      })

      assert builder.save, "should save: #{builder.errors.full_messages}"
      rt = builder.saved_recurring_todo

      assert_equal 2, builder.pattern.every_x_month2
      assert_equal 2, rt.every_other2
    end

    def test_validations
      rt = @admin.recurring_todos.where(recurring_period: 'monthly').first
      assert rt.valid?, "should be valid at start: #{rt.errors.full_messages}"

      rt.recurrence_selector = 0 # 'monthly_every_x_day'
      rt.every_other2 = nil
      assert !rt.valid?, "should not be valid since every_x_month is empty"

      rt.recurrence_selector = 1 # 'monthly_every_xth_day'
      rt.every_other2 = nil
      assert !rt.valid?, "should not be valid since every_xth_month is empty"

      rt.every_count = nil
      assert !rt.valid?, "should not be valid since day_of_week is empty"
    end

    def test_pattern_text
      rt = recurring_todos(:check_with_bill_every_last_friday_of_month)
      assert_equal "every last friday of every 2 months", rt.recurrence_pattern

      rt.every_other2 = 1
      assert_equal "every last friday of every month", rt.recurrence_pattern

      rt.recurrence_selector = 0
      assert_equal "every 5 months on day 1", rt.recurrence_pattern

      rt.every_other3 = 1
      assert_equal "every month on day 1", rt.recurrence_pattern
    end

  end

end