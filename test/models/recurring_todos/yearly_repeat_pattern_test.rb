require_relative '../../test_helper'

module RecurringTodos

  class YearlyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_valid_selector
      attributes = {
        'recurring_period'    => 'yearly'
      }

      # should not raise
      %w{yearly_every_x_day yearly_every_xth_day}.each do |selector|
        attributes['yearly_selector'] = selector
        YearlyRepeatPattern.new(@admin, attributes)
      end

      # should raise
      attributes = {
        'recurring_period' => 'yearly',
        'yearly_selector'  => 'wrong value'
      }

      # should raise
      assert_raise(Exception, "should have exception since yearly_selector has wrong value"){ YearlyRepeatPattern.new(@admin, attributes) }
    end

    def test_mapping_of_attributes
      attributes = {
        'recurring_period'      => 'yearly',
        'description'           => 'a repeating todo',   # generic
        'yearly_selector'       => 'yearly_every_x_day', # yearly specific 
        'yearly_every_x_day'    => '5',                  # mapped to every_other1
        'yearly_every_xth_day'  => '7',                  # mapped to every_other3
        'yearly_day_of_week'    => '3',                  # mapped to every_count
        'yearly_month_of_year'  => '1',                  # mapped to evert_other2 because yearly_selector is yearly_every_x_day
        'yearly_month_of_year2' => '2'                   # ignored because yearly_selector is yearly_every_x_day
      }

      pattern = YearlyRepeatPattern.new(@admin, attributes)

      assert_equal '5',   pattern.mapped_attributes[:every_other1], "every_other1 should be set to yearly_every_x_day"
      assert_equal '1',   pattern.mapped_attributes[:every_other2], "every_other2 should be set to yearly_month_of_year because selector is yearly_every_x_day"
      assert_equal '7',   pattern.mapped_attributes[:every_other3], "every_other3 should be set to yearly_every_xth_day"
      assert_equal '3',   pattern.mapped_attributes[:every_count],  "every_count should be set to yearly_day_of_week"

      attributes = {
        'recurring_period'      => 'yearly',
        'description'           => 'a repeating todo',     # generic
        'yearly_selector'       => 'yearly_every_xth_day', # daily specific --> mapped to only_work_days=false
        'yearly_month_of_year'  => '1',                    # ignored because yearly_selector is yearly_every_xth_day
        'yearly_month_of_year2' => '2'                     # mapped to evert_other2 because yearly_selector is yearly_every_xth_day
      }

      pattern = YearlyRepeatPattern.new(@admin, attributes)
      assert_equal '2',   pattern.mapped_attributes[:every_other2], "every_other2 should be set to yearly_month_of_year2 because selector is yearly_every_xth_day"
    end

  end

end