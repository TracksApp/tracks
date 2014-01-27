require_relative '../../test_helper'

module RecurringTodos

  class DailyRecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_pattern_is_daily
      object = RecurringTodosBuilder.new(@admin, { 'recurring_period' => 'daily', 'daily_selector' => 'daily_every_x_day' })
      assert object.builder.is_a? DailyRecurringTodosBuilder
    end

    def test_filter_non_daily_attributes
      attributes = {
        'recurring_period' => 'daily',
        'description'      => 'a repeating todo',  # generic
        'daily_selector'   => 'daily_every_x_day', # daily specific
        'bla_bla'          => 'go away'            # irrelevant for daily
      }

      result = RecurringTodosBuilder.new(@admin, attributes).attributes
      
      assert_nil   result['bla_bla'],   "bla_bla should be filtered"
      assert_nil   result[:bla_bla],    "bla_bla should be filtered"
      assert_equal false, result[:only_work_days], "daily attributes should be preserved"
      assert_equal "a repeating todo",  result[:description], "description should be preserved"
    end

  end

end