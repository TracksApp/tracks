require 'test_helper'

module RecurringTodos

  class MonthlyRecurrencePatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      super
      @admin = users(:admin_user)
    end

    def test_attribute_mapping
      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'monthly',
        'description'            => 'a recurring todo',    # generic
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

      assert builder.pattern.is_a?(MonthlyRecurrencePattern), "should be monthly pattern, but is #{builder.pattern.class}"
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
        'description'            => 'a recurring todo',    # generic
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
        'description'            => 'a recurring todo',    # generic
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
      assert_equal "every month on day 1", rt.recurrence_pattern

      rt.every_other2 = 4
      assert_equal "every 4 months on day 1", rt.recurrence_pattern
    end

    def test_monthly_pattern
      @monthly_every_last_friday = recurring_todos(:check_with_bill_every_last_friday_of_month)
      
      due_date = @monthly_every_last_friday.get_due_date(@sunday)
      assert_equal Time.zone.local(2008,6,27), due_date

      friday_is_last_day_of_month = Time.zone.local(2008,10,31)
      due_date = @monthly_every_last_friday.get_due_date(friday_is_last_day_of_month-1.day )
      assert_equal friday_is_last_day_of_month , due_date

      @monthly_every_third_friday = @monthly_every_last_friday
      @monthly_every_third_friday.every_other3=3 #third
      due_date = @monthly_every_last_friday.get_due_date(@sunday) # june 8th 2008
      assert_equal Time.zone.local(2008, 6, 20), due_date
      # set date past third friday of this month
      due_date = @monthly_every_last_friday.get_due_date(Time.zone.local(2008,6,21)) # june 21th 2008
      assert_equal Time.zone.local(2008, 8, 15), due_date    # every 2 months, so aug

      @monthly = @monthly_every_last_friday
      @monthly.recurrence_selector=0
      @monthly.every_other1 = 8  # every 8th day of the month
      @monthly.every_other2 = 2  # every 2 months

      due_date = @monthly.get_due_date(@saturday) # june 7th
      assert_equal @sunday, due_date # june 8th

      due_date = @monthly.get_due_date(@sunday) # june 8th
      assert_equal Time.zone.local(2008,8,8), due_date # aug 8th
    end

  end

end