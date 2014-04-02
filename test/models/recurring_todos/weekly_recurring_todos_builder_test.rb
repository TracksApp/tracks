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
      
      assert_nil   result.get('bla_bla'),   "bla_bla should be filtered"
      assert_nil   result.get(:bla_bla),    "bla_bla should be filtered"
      assert_equal ' m     ',           result.get(:every_day), "weekly attributes should be preserved"
      assert_equal "a repeating todo",  result.get(:description), "description should be preserved"
    end

    def test_attributes_to_filter
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_return_monday' => 'm',                 # weekly specific
      })

      w = WeeklyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal 9, w.attributes_to_filter.size
      assert w.attributes_to_filter.include?('weekly_selector'), "attributes_to_filter should return static attribute weekly_selector"
      assert w.attributes_to_filter.include?('weekly_return_monday'), "attributes_to_filter should return generated weekly_return_xyz"
    end

    def test_mapping_of_attributes
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_every_x_week'  => '5',                 # mapped to every_other1
        'weekly_return_monday' => 'm'
      })

      pattern = WeeklyRecurringTodosBuilder.new(@admin, attributes)

      assert_equal '5', pattern.mapped_attributes.get(:every_other1), "every_other1 should be set to weekly_every_x_week"
      assert_equal ' m     ', pattern.mapped_attributes.get(:every_day), "weekly_return_<weekday> should be mapped to :every_day in format 'smtwtfs'"
    end

    def test_map_day
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_every_x_week'  => '5'                  # mapped to every_other1
      })

      pattern = WeeklyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal '       ', pattern.mapped_attributes.get(:every_day), "all days should be empty in :every_day"

      # add all days
      { sunday: 's', monday: 'm', tuesday: 't', wednesday: 'w', thursday: 't', friday: 'f', saturday: 's' }.each do |day, short|
        attributes.set("weekly_return_#{day}", short)
      end

      pattern = WeeklyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal 'smtwtfs', pattern.mapped_attributes.get(:every_day), "all days should be filled in :every_day"

      # remove wednesday
      attributes = attributes.except('weekly_return_wednesday')
      pattern = WeeklyRecurringTodosBuilder.new(@admin, attributes)
      assert_equal 'smt tfs', pattern.mapped_attributes.get(:every_day), "only wednesday should be empty in :every_day"
    end


  end

end