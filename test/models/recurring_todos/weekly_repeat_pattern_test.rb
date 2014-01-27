require_relative '../../test_helper'

module RecurringTodos

  class WeeklyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_mapping_of_attributes
      attributes = {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_every_x_week'  => '5',                 # mapped to every_other1
        'weekly_return_monday' => 'm'
      }

      pattern = WeeklyRepeatPattern.new(@admin, attributes)

      assert_equal '5', pattern.mapped_attributes[:every_other1], "every_other1 should be set to weekly_every_x_week"
      assert_equal ' m     ', pattern.mapped_attributes[:every_day], "weekly_return_<weekday> should be mapped to :every_day in format 'smtwtfs'"
    end

    def test_map_day
      attributes = {
        'recurring_period'     => 'weekly',
        'description'          => 'a repeating todo',  # generic
        'weekly_every_x_week'  => '5'                  # mapped to every_other1
      }

      pattern = WeeklyRepeatPattern.new(@admin, attributes)
      assert_equal '       ', pattern.mapped_attributes[:every_day], "all days should be empty in :every_day"

      # add all days
      { sunday: 's', monday: 'm', tuesday: 't', wednesday: 'w', thursday: 't', friday: 'f', saturday: 's' }.each do |day, short|
        attributes["weekly_return_#{day}"] = short
      end

      pattern = WeeklyRepeatPattern.new(@admin, attributes)
      assert_equal 'smtwtfs', pattern.mapped_attributes[:every_day], "all days should be filled in :every_day"

      # remove wednesday
      attributes = attributes.except('weekly_return_wednesday')
      pattern = WeeklyRepeatPattern.new(@admin, attributes)
      assert_equal 'smt tfs', pattern.mapped_attributes[:every_day], "only wednesday should be empty in :every_day"
    end

  end

end