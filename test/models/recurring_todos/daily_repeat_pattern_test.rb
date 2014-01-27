require_relative '../../test_helper'

module RecurringTodos

  class DailyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_valid_selector
      attributes = {
        'recurring_period'    => 'daily'
      }

      # should not raise
      %w{daily_every_x_day daily_every_work_day}.each do |selector|
        attributes['daily_selector'] = selector
        DailyRepeatPattern.new(@admin, attributes)
      end

      # should raise
      attributes = {
        'recurring_period'    => 'daily',
        'daily_selector'      => 'wrong value'
      }

      # should raise
      assert_raise(Exception, "should have exception since daily_selector has wrong value"){ DailyRepeatPattern.new(@admin, attributes) }
    end

    def test_mapping_of_attributes
      attributes = {
        'recurring_period'    => 'daily',
        'description'         => 'a repeating todo',  # generic
        'daily_selector'      => 'daily_every_x_day', # daily specific --> mapped to only_work_days=false
        'daily_every_x_days'  => '5'                  # mapped to every_other1
      }

      pattern = DailyRepeatPattern.new(@admin, attributes)

      assert_equal '5', pattern.mapped_attributes[:every_other1], "every_other1 should be set to daily_every_x_days"
      assert_equal false, pattern.mapped_attributes[:only_work_days], "only_work_days should be set to false for daily_every_x_day"

      attributes = {
        'recurring_period'    => 'daily',
        'description'         => 'a repeating todo',     # generic
        'daily_selector'      => 'daily_every_work_day', # daily specific --> mapped to only_work_days=true
      }

      pattern = DailyRepeatPattern.new(@admin, attributes)
      assert_equal true, pattern.mapped_attributes[:only_work_days]
    end

  end

end