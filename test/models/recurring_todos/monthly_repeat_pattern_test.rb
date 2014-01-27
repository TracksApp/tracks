require_relative '../../test_helper'

module RecurringTodos

  class MonthlyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_valid_selector
      attributes = {
        'recurring_period'    => 'monthly'
      }

      # should not raise
      %w{monthly_every_x_day monthly_every_xth_day}.each do |selector|
        attributes['monthly_selector'] = selector
        MonthlyRepeatPattern.new(@admin, attributes)
      end

      # should raise
      attributes = {
        'recurring_period'    => 'monthly',
        'monthly_selector'      => 'wrong value'
      }

      # should raise
      assert_raise(Exception, "should have exception since monthly_selector has wrong value"){ MonthlyRepeatPattern.new(@admin, attributes) }
    end

    def test_mapping_of_attributes
      attributes = {
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',    # generic
        'monthly_selector'       => 'monthly_every_x_day', # monthly specific 
        'monthly_every_x_day'    => '5',                   # mapped to :every_other1
        'monthly_every_xth_day'  => '7',                   # mapped to :every_other3
        'monthly_day_of_week'    => 3,                     # mapped to :every_count
        'monthly_every_x_month'  => '10',                  # mapped to :every_other2   
        'monthly_every_x_month2' => '20'                   # not mapped
      }

      pattern = MonthlyRepeatPattern.new(@admin, attributes)
      assert_equal 0,    pattern.mapped_attributes[:recurrence_selector], "selector should be 0 for monthly_every_x_day"
      assert_equal '5',  pattern.mapped_attributes[:every_other1],        "every_other1 should be set to monthly_every_x_days"
      assert_equal '10', pattern.mapped_attributes[:every_other2],        "every_other2 should be set to monthly_every_x_month when selector is monthly_every_x_day (=0)"
      assert_equal '7',  pattern.mapped_attributes[:every_other3],        "every_other3 should be set to monthly_every_xth_day"
      assert_equal 3,    pattern.mapped_attributes[:every_count],         "every_count should be set to monthly_day_of_week"

      pattern.build_recurring_todo
      assert pattern.every_x_day?, "every_x_day? should say true for selector monthly_every_x_day"

      attributes = {
        'recurring_period'       => 'monthly',
        'description'            => 'a repeating todo',      # generic
        'monthly_selector'       => 'monthly_every_xth_day', # monthly specific 
        'monthly_every_x_day'    => '5',                     # mapped to :every_other1
        'monthly_every_x_month'  => '10',                    # not mapped
        'monthly_every_x_month2' => '20'                     # mapped to :every_other2   
      }

      pattern = MonthlyRepeatPattern.new(@admin, attributes)
      assert_equal 1,    pattern.mapped_attributes[:recurrence_selector], "selector should be 1 for monthly_every_xth_day"
      assert_equal '20', pattern.mapped_attributes[:every_other2],        "every_other2 should be set to monthly_every_x_month2 when selector is monthly_every_xth_day (=0)"

      pattern.build_recurring_todo
      assert pattern.every_xth_day?, "every_xth_day? should say true for selector monthly_every_xth_day"
    end

  end

end