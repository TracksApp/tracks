require_relative '../../test_helper'

module RecurringTodos

  class YearlyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_attribute_mapping
      builder = RecurringTodosBuilder.new(@admin, { 
        'recurring_period'       => 'yearly',
        'description'            => 'a repeating todo',    # generic
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

      assert builder.pattern.is_a?(YearlyRepeatPattern), "should be monthly pattern, but is #{builder.pattern.class}"

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

  end

end