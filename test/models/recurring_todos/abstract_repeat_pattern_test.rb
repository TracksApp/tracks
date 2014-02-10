require_relative '../../test_helper'

module RecurringTodos

  class AbstractRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_pattern_builds_from_existing_recurring_todo
      rt = @admin.recurring_todos.first

      pattern = rt.pattern
      assert pattern.is_a?(DailyRepeatPattern), "recurring todo should have daily pattern"
    end

    def test_validation_on_due_date
      attributes = {
        'recurring_period'     => 'weekly',
        'recurring_target'     => 'due_date',
        'description'          => 'a repeating todo',  # generic
        'weekly_return_monday' => 'm',                 # weekly specific
        'ends_on'              => 'ends_on_end_date',
        'end_date'             => Time.zone.now + 1.week,
        'context_id'           => @admin.contexts.first.id,
        'start_from'           => Time.zone.now - 1.week,
        'weekly_every_x_week'  => 1,
      }

      pattern = create_pattern(attributes)
      assert !pattern.valid?, "should fail because show_always and show_from_delta are not there"

      attributes['recurring_show_always'] = false
      pattern = create_pattern(attributes)
      assert !pattern.valid?, "should fail because show_from_delta is not there"

      attributes[:recurring_show_days_before] = 5
      pattern = create_pattern(attributes)
      assert pattern.valid?, "should be valid:" + pattern.errors.full_messages.to_s
    end

    def test_validation_on_start_date
      attributes = {
        'recurring_period'           => 'weekly',
        'recurring_target'           => 'due_date',
        'description'                => 'a repeating todo',  # generic
        'weekly_return_monday'       => 'm',                 # weekly specific
        'ends_on'                    => 'ends_on_end_date',
        'context_id'                 => @admin.contexts.first.id,
        'end_date'                   => Time.zone.now + 1.week,
        'weekly_every_x_week'        => 1,
        'recurring_show_always'      => false,
        'recurring_show_days_before' => 5,
      }
      pattern = create_pattern(attributes)
      assert !pattern.valid?, "should be not valid because start_from is empty"

      attributes['start_from'] = Time.zone.now - 1.week
      pattern = create_pattern(attributes)
      assert pattern.valid?, "should be valid: " + pattern.errors.full_messages.to_s
    end

    def test_validation_on_end_date
      attributes = {
        'recurring_period'           => 'weekly',
        'recurring_target'           => 'due_date',
        'description'                => 'a repeating todo',  # generic
        'weekly_return_monday'       => 'm',                 # weekly specific
        'ends_on'                    => 'invalid_value',
        'context_id'                 => @admin.contexts.first.id,
        'start_from'                 => Time.zone.now - 1.week,
        'weekly_every_x_week'        => 1,
        'recurring_show_always'      => false,
        'recurring_show_days_before' => 5,
      }

      pattern = create_pattern(attributes)
      assert !pattern.valid?

      attributes['ends_on']='ends_on_end_date'
      pattern = create_pattern(attributes)
      assert !pattern.valid?, "should not be valid, because end_date is not supplied"

      attributes['end_date']= Time.zone.now + 1.week
      pattern = create_pattern(attributes)
      assert pattern.valid?, "should be valid"
    end

    private

    def create_pattern(attributes)
      builder = RecurringTodosBuilder.new(@admin, attributes)
      builder.build
      builder.pattern
    end

  end

end