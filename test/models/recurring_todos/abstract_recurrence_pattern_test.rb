require 'test_helper'

module RecurringTodos

  class AbstractRecurrencePatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      super
      @admin = users(:admin_user)
    end

    def test_pattern_builds_from_existing_recurring_todo
      rt = @admin.recurring_todos.first

      pattern = rt.pattern
      assert pattern.is_a?(DailyRecurrencePattern), "recurring todo should have daily pattern"
    end

    def test_validation_on_due_date
      attributes = {
        'weekly_every_x_week'  => 1,
        'weekly_return_monday' => 'm',                 # weekly specific
      }

      pattern = create_recurring_todo(attributes)
      assert !pattern.valid?, "should fail because show_always and show_from_delta are not there"

      attributes['recurring_show_always'] = false
      pattern = create_recurring_todo(attributes)
      assert !pattern.valid?, "should fail because show_from_delta is not there"

      attributes[:recurring_show_days_before] = 5
      pattern = create_recurring_todo(attributes)
      assert pattern.valid?, "should be valid:" + pattern.errors.full_messages.to_s
    end

    def test_validation_on_start_date
      attributes = {
        'weekly_every_x_week'        => 1,
        'weekly_return_monday'       => 'm',                 # weekly specific
        'recurring_show_always'      => false,
        'recurring_show_days_before' => 5,
        'start_from'                 => nil
      }
      pattern = create_recurring_todo(attributes)
      assert !pattern.valid?, "should be not valid because start_from is empty"

      attributes['start_from'] = Time.zone.now - 1.week
      pattern = create_recurring_todo(attributes)
      assert pattern.valid?, "should be valid: " + pattern.errors.full_messages.to_s
    end

    def test_validation_on_end_date
      attributes = {
        'weekly_return_monday'       => 'm',                 # weekly specific
        'ends_on'                    => 'invalid_value',
        'weekly_every_x_week'        => 1,
        'recurring_show_always'      => false,
        'recurring_show_days_before' => 5,
      }

      pattern = create_recurring_todo(attributes)
      assert !pattern.valid?

      attributes['ends_on']='ends_on_end_date'
      attributes['end_date']=nil
      pattern = create_recurring_todo(attributes)
      assert !pattern.valid?, "should not be valid, because end_date is not supplied"

      attributes['end_date']= Time.zone.now + 1.week
      pattern = create_recurring_todo(attributes)
      assert pattern.valid?, "should be valid"
    end

    def test_validation_on_number_of_occurrences
      attributes = {
        'weekly_return_monday'       => 'm',                 # weekly specific
        'weekly_every_x_week'        => 1,
        'recurring_show_always'      => false,
        'recurring_show_days_before' => 5,
        'ends_on' => 'ends_on_number_of_times',
      }

#      pattern = create_recurring_todo(attributes)
#      assert !pattern.valid?, "number_of_occurrences should be filled"

      attributes['number_of_occurrences']=5
      pattern = create_recurring_todo(attributes)
      assert pattern.valid?, "should be valid"
    end


    def test_end_date_on_recurring_todo
      rt = recurring_todos(:call_bill_gates_every_day)

      assert_equal true, rt.continues_recurring?(@in_three_days)
      assert_equal true, rt.continues_recurring?(@in_four_days)
      rt.end_date = @in_four_days
      rt.ends_on = 'ends_on_end_date'
      assert_equal false, rt.continues_recurring?(@in_four_days)
    end

    def test_continues_recurring
      rt = recurring_todos(:call_bill_gates_every_day)
      assert rt.continues_recurring?(Time.zone.now), "should not end"

      rt.end_date = Time.zone.now - 1.day
      rt.ends_on = 'ends_on_end_date'
      assert !rt.continues_recurring?(Time.zone.now), "should end because end_date is in the past"

      rt.reload # reset
      rt.number_of_occurrences = 2
      rt.occurrences_count = 1
      assert rt.continues_recurring?(Time.zone.now), "should continue since there still may come occurrences"

      rt.occurrences_count = 2
      assert !rt.continues_recurring?(Time.zone.now), "should end since all occurrences are there"
    end

    def test_determine_start
      travel_to Time.zone.local(2013,1,1) do
        rt = create_recurring_todo
        assert_equal Time.zone.parse("2013-01-01 00:00:00"), rt.send(:determine_start, nil), "no previous date, use today"
        assert_equal Time.zone.parse("2013-01-01 00:00:00"), rt.send(:determine_start, nil, 1.day).to_s(:db), "no previous date, use today without offset"
        assert_equal Time.zone.parse("2013-01-02 00:00:00"), rt.send(:determine_start, Time.zone.now, 1.day).to_s(:db), "use previous date and offset"
      end
    end

    def test_xth_day_of_month
      rt = create_recurring_todo

      # march 2014 has 5 saturdays, the last will return the 5th
      assert_equal Time.zone.parse("2014-03-01 00:00:00"), rt.send(:get_xth_day_of_month, 1, 6, 3, 2014).to_s(:db)
      assert_equal Time.zone.parse("2014-03-22 00:00:00"), rt.send(:get_xth_day_of_month, 4, 6, 3, 2014).to_s(:db)
      assert_equal Time.zone.parse("2014-03-29 00:00:00"), rt.send(:get_xth_day_of_month, 5, 6, 3, 2014).to_s(:db)

      # march 2014 has 4 fridays, the last will return the 4th
      assert_equal Time.zone.parse("2014-03-07 00:00:00"), rt.send(:get_xth_day_of_month, 1, 5, 3, 2014).to_s(:db)
      assert_equal Time.zone.parse("2014-03-28 00:00:00"), rt.send(:get_xth_day_of_month, 4, 5, 3, 2014).to_s(:db)
      assert_equal Time.zone.parse("2014-03-28 00:00:00"), rt.send(:get_xth_day_of_month, 5, 5, 3, 2014).to_s(:db)

      assert_raise(RuntimeError, "should check on valid weekdays"){ rt.send(:get_xth_day_of_month, 5, 9, 3, 2014) }
      assert_raise(RuntimeError, "should check on valid count x"){ rt.send(:get_xth_day_of_month, 6, 5, 3, 2014) }
    end

    private

    def create_pattern(attributes)
      builder = RecurringTodosBuilder.new(@admin, attributes)
      builder.build
      builder.pattern
    end

    def create_recurring_todo(attributes={})
      create_pattern(attributes.reverse_merge({
        'recurring_period'     => 'weekly',
        'recurring_target'     => 'due_date',
        'description'          => 'a recurring todo',  # generic
        'ends_on'              => 'ends_on_end_date',
        'end_date'             => Time.zone.now + 1.week,
        'context_id'           => @admin.contexts.first.id,
        'start_from'           => Time.zone.now - 1.week,
        }))
    end

  end

end
