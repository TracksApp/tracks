require_relative '../../test_helper'

module RecurringTodos

  class MonthlyRecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_pattern_is_monthly
      object = RecurringTodosBuilder.new(@admin, { 'recurring_period' => 'monthly', 'monthly_selector' => 'monthly_every_x_day' })
      assert object.builder.is_a?(MonthlyRecurringTodosBuilder), "Builder should be of type MonthlyRecurringTodosBuilder"
    end

    def test_filter_non_daily_attributes
      attributes = {
        'recurring_period'    => 'monthly',
        'description'         => 'a repeating todo',    # generic
        'monthly_selector'    => 'monthly_every_x_day', # monthly specific
        'monthly_every_x_day' => 5,                     # should be preserved as :every_other1
        'bla_bla'             => 'go away'              # irrelevant for daily
      }

      result = RecurringTodosBuilder.new(@admin, attributes).attributes
      
      assert_nil   result['bla_bla'],   "bla_bla should be filtered"
      assert_nil   result[:bla_bla],    "bla_bla should be filtered"
      assert_equal 5,  result[:every_other1], "should be preserved"
    end

  end

end