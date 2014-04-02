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
      
      assert_nil   result.get('bla_bla'),   "bla_bla should be filtered"
      assert_nil   result.get(:bla_bla),    "bla_bla should be filtered"
      assert_equal 5,  result.get(:every_other1), "should be preserved"
    end

    def test_valid_selector
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'monthly'
      })

      # should not raise
      %w{monthly_every_x_day monthly_every_xth_day}.each do |selector|
        attributes.set('monthly_selector', selector)
        MonthlyRecurringTodosBuilder.new(@admin, attributes)
      end

      # should raise
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'monthly',
        'monthly_selector'      => 'wrong value'
      })

      # should raise
      assert_raise(Exception, "should have exception since monthly_selector has wrong value"){ MonthlyRecurringTodosBuilder.new(@admin, attributes) }
    end

    def test_mapping_of_attributes
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',    # generic
        'monthly_selector'       => 'monthly_every_x_day', # monthly specific 
        'monthly_every_x_day'    => '5',                   # mapped to :every_other1
        'monthly_every_xth_day'  => '7',                   # mapped to :every_other3
        'monthly_day_of_week'    => 3,                     # mapped to :every_count
        'monthly_every_x_month'  => '10',                  # mapped to :every_other2   
        'monthly_every_x_month2' => '20'                   # not mapped
      })

      builder = MonthlyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal 0,    builder.mapped_attributes.get(:recurrence_selector), "selector should be 0 for monthly_every_x_day"
      assert_equal '5',  builder.mapped_attributes.get(:every_other1),        "every_other1 should be set to monthly_every_x_days"
      assert_equal '10', builder.mapped_attributes.get(:every_other2),        "every_other2 should be set to monthly_every_x_month when selector is monthly_every_x_day (=0)"
      assert_equal '7',  builder.mapped_attributes.get(:every_other3),        "every_other3 should be set to monthly_every_xth_day"
      assert_equal 3,    builder.mapped_attributes.get(:every_count),         "every_count should be set to monthly_day_of_week"

      builder.build
      assert builder.pattern.every_x_day?, "every_x_day? should say true for selector monthly_every_x_day"

      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',      # generic
        'monthly_selector'       => 'monthly_every_xth_day', # monthly specific 
        'monthly_every_x_day'    => '5',                     # mapped to :every_other1
        'monthly_every_x_month'  => '10',                    # not mapped
        'monthly_every_x_month2' => '20'                     # mapped to :every_other2   
      })

      builder = MonthlyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal 1,    builder.mapped_attributes.get(:recurrence_selector), "selector should be 1 for monthly_every_xth_day"
      assert_equal '20', builder.mapped_attributes.get(:every_other2),        "every_other2 should be set to monthly_every_x_month2 when selector is monthly_every_xth_day (=0)"

      builder.build
      assert builder.pattern.every_xth_day?, "every_xth_day? should say true for selector monthly_every_xth_day"
    end

  end

end