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
      
      assert_nil   result.get('bla_bla'),   "bla_bla should be filtered"
      assert_nil   result.get(:bla_bla),    "bla_bla should be filtered"
      assert_equal false, result.get(:only_work_days), "daily attributes should be preserved"
      assert_equal "a repeating todo",  result.get(:description), "description should be preserved"
    end

    def test_valid_selector
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'daily'
      })

      # should not raise
      %w{daily_every_x_day daily_every_work_day}.each do |selector|
        attributes.set('daily_selector', selector)
        DailyRecurringTodosBuilder.new(@admin, attributes)
      end

      # should raise
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'daily',
        'daily_selector'      => 'wrong value'
      })

      # should raise
      assert_raise(Exception, "should have exception since daily_selector has wrong value"){ DailyRecurringTodosBuilder.new(@admin, attributes) }
    end

    def test_mapping_of_attributes
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'daily',
        'description'         => 'a repeating todo',  # generic
        'daily_selector'      => 'daily_every_x_day', # daily specific --> mapped to only_work_days=false
        'daily_every_x_days'  => '5'                  # mapped to every_other1
      })

      pattern = DailyRecurringTodosBuilder.new(@admin, attributes)

      assert_equal '5', pattern.mapped_attributes.get(:every_other1), "every_other1 should be set to daily_every_x_days"
      assert_equal false, pattern.mapped_attributes.get(:only_work_days), "only_work_days should be set to false for daily_every_x_day"

      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'daily',
        'description'         => 'a repeating todo',     # generic
        'daily_selector'      => 'daily_every_work_day', # daily specific --> mapped to only_work_days=true
      })

      pattern = DailyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal true, pattern.mapped_attributes.get(:only_work_days)
    end

  end

end