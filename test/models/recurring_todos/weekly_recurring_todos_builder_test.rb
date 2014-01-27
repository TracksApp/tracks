require_relative '../../test_helper'

module RecurringTodos

  class WeeklyRecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_pattern_is_weekly
      object = RecurringTodosBuilder.new(@admin, { 'recurring_period' => 'weekly' })
      assert object.builder.is_a? WeeklyRecurringTodosBuilder
    end

    def test_filter_non_daily_attributes
      attributes = {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_return_monday' => 'm',                 # weekly specific
        'bla_bla'              => 'go away'            # irrelevant 
      }

      result = RecurringTodosBuilder.new(@admin, attributes).attributes
      
      assert_nil   result['bla_bla'],   "bla_bla should be filtered"
      assert_nil   result[:bla_bla],    "bla_bla should be filtered"
      assert_equal ' m     ',           result[:every_day], "weekly attributes should be preserved"
      assert_equal "a repeating todo",  result[:description], "description should be preserved"
    end

  end

end