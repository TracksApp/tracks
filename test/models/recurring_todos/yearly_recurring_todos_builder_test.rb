require_relative '../../test_helper'

module RecurringTodos

  class YearlyRecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_pattern_is_yearly
      object = RecurringTodosBuilder.new(@admin, { 'recurring_period' => 'yearly', 'yearly_selector' => 'yearly_every_x_day' })
      assert object.builder.is_a? YearlyRecurringTodosBuilder
    end

    def test_filter_non_daily_attributes
      attributes = {
        'recurring_period'     => 'yearly',
        'description'          => 'a repeating todo',   # generic
        'yearly_selector'      => 'yearly_every_x_day', # daily specific
        'yearly_month_of_year' => '1',                  # mapped to evert_other2 because yearly_selector is yearly_every_x_day
        'bla_bla'              => 'go away'             # irrelevant for daily
      }

      result = RecurringTodosBuilder.new(@admin, attributes).attributes

      assert_nil   result.get('bla_bla'),                         "bla_bla should be filtered"
      assert_nil   result.get(:bla_bla),                          "bla_bla should be filtered"
      assert_equal '1', result.get(:every_other2),                "yearly attributes should be preserved"
      assert_equal "a repeating todo",  result.get(:description), "description should be preserved"
    end

    def test_valid_selector
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period'    => 'yearly'
      })

      # should not raise
      %w{yearly_every_x_day yearly_every_xth_day}.each do |selector|
        attributes.set(:yearly_selector, selector)
        YearlyRecurringTodosBuilder.new(@admin, attributes)
      end

      # should raise
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period' => 'yearly',
        'yearly_selector'  => 'wrong value'
      })

      # should raise
      assert_raise(Exception, "should have exception since yearly_selector has wrong value"){ YearlyRecurringTodosBuilder.new(@admin, attributes) }
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

      pattern = YearlyRecurringTodosBuilder.new(@admin, Tracks::AttributeHandler.new(@admin, attributes))

      assert_equal '5',   pattern.mapped_attributes.get(:every_other1), "every_other1 should be set to yearly_every_x_day"
      assert_equal '1',   pattern.mapped_attributes.get(:every_other2), "every_other2 should be set to yearly_month_of_year because selector is yearly_every_x_day"
      assert_equal '7',   pattern.mapped_attributes.get(:every_other3), "every_other3 should be set to yearly_every_xth_day"
      assert_equal '3',   pattern.mapped_attributes.get(:every_count),  "every_count should be set to yearly_day_of_week"

      attributes = {
        'recurring_period'      => 'yearly',
        'description'           => 'a repeating todo',     # generic
        'yearly_selector'       => 'yearly_every_xth_day', # daily specific --> mapped to only_work_days=false
        'yearly_month_of_year'  => '1',                    # ignored because yearly_selector is yearly_every_xth_day
        'yearly_month_of_year2' => '2'                     # mapped to evert_other2 because yearly_selector is yearly_every_xth_day
      }

      pattern = YearlyRecurringTodosBuilder.new(@admin, Tracks::AttributeHandler.new(@admin, attributes))
      assert_equal '2',   pattern.mapped_attributes.get(:every_other2), "every_other2 should be set to yearly_month_of_year2 because selector is yearly_every_xth_day"
    end

  end

end