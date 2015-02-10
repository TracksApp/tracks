require 'test_helper'

module RecurringTodos

  class YearlyRecurrencePatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      super
      @admin = users(:admin_user)
    end 

    def test_attribute_mapping
      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'yearly',
        'description'            => 'a recurring todo',    # generic
        'recurring_target'       => 'show_from_date',
        'ends_on'                => 'ends_on_end_date',
        'end_date'               => Time.zone.now + 1.week,
        'start_from'             => Time.zone.now,
        'context_name'           => @admin.contexts.first.name,
        'yearly_selector'        => 'yearly_every_x_day',
        'yearly_every_x_day'     => 5,
        'yearly_every_xth_day'   => 6,
        'yearly_month_of_year'   => 7,
        'yearly_month_of_year2'  => 8,
        'yearly_day_of_week'     => 9
      })

      assert builder.save, "should save: #{builder.errors.full_messages}"
      rt = builder.saved_recurring_todo

      assert builder.pattern.is_a?(YearlyRecurrencePattern), "should be yearly pattern, but is #{builder.pattern.class}"

      assert_equal rt.recurrence_selector, builder.pattern.recurrence_selector
      assert_equal rt.every_other2,        builder.pattern.month_of_year
      assert_equal rt.every_other1,        builder.pattern.every_x_day
      assert_equal rt.every_other3,        builder.pattern.every_xth_day
      assert_equal rt.every_count,         builder.pattern.day_of_week
      assert_equal Time.zone.now.month,    builder.pattern.month_of_year2, "uses default for moy2, which is current month"

      rt.recurrence_selector = 1 # 'yearly_every_xth_day'
      assert_equal rt.every_other2, rt.pattern.month_of_year2, "uses every_other2 for moy2 when yearly_every_xth_day"
    end

    def test_validations
      rt = @admin.recurring_todos.where(recurring_period: 'yearly').first
      assert rt.valid?, "should be valid at start: #{rt.errors.full_messages}"

      rt.recurrence_selector = 0 # 'yearly_every_x_day'
      rt.every_other1 = nil
      assert !rt.valid?, "should not be valid since every_x_day is empty"
      rt.every_other1 = 1
      rt.every_other2 = nil
      assert !rt.valid?, "should not be valid since month_of_year is empty"

      rt.recurrence_selector = 1 # 'yearly_every_xth_day'
      rt.every_other2 = nil
      assert !rt.valid?, "should not be valid since month_of_year2 is empty"
      rt.every_other2 = 1
      rt.every_other3 = nil
      assert !rt.valid?, "should not be valid since every_xth_day is empty"
      rt.every_other3 = 1
      rt.every_count = nil
      assert !rt.valid?, "should not be valid since day_of_week is empty"
    end

    def test_pattern_text
      rt = recurring_todos(:birthday_reinier)
      assert_equal "every year on June 08", rt.recurrence_pattern

      rt.recurrence_selector = 1
      rt.every_count = 3
      rt.every_other3 = 3
      assert_equal "every year on the third wednesday of June", rt.recurrence_pattern
    end

    def test_yearly_pattern
      @yearly = recurring_todos(:birthday_reinier)

      # beginning of same year
      due_date = @yearly.get_due_date(Time.zone.local(2008,2,10)) # feb 10th
      assert_equal @sunday, due_date # june 8th

      # same month, previous date
      due_date = @yearly.get_due_date(@saturday) # june 7th
      show_from_date = @yearly.get_show_from_date(@saturday) # june 7th
      assert_equal @sunday, due_date # june 8th
      assert_equal @sunday-5.days, show_from_date

      # same month, day after
      due_date = @yearly.get_due_date(@monday) # june 9th
      assert_equal Time.zone.local(2009,6,8), due_date # june 8th next year
      # very overdue
      due_date = @yearly.get_due_date(@monday+5.months-2.days) # november 7
      assert_equal Time.zone.local(2009,6,8), due_date # june 8th next year

      @yearly.recurrence_selector = 1
      @yearly.every_other3 = 2 # second
      @yearly.every_count = 3 # wednesday
      # beginning of same year
      due_date = @yearly.get_due_date(Time.zone.local(2008,2,10)) # feb 10th
      assert_equal Time.zone.local(2008,6,11), due_date # june 11th
      # same month, before second wednesday
      due_date = @yearly.get_due_date(@saturday) # june 7th
      assert_equal Time.zone.local(2008,6,11), due_date # june 11th
      # same month, after second wednesday
      due_date = @yearly.get_due_date(Time.zone.local(2008,6,12)) # june 7th
      assert_equal Time.zone.local(2009,6,10), due_date # june 10th
    end


  end

end