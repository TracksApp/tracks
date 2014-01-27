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
      
      assert_nil   result['bla_bla'],                         "bla_bla should be filtered"
      assert_nil   result[:bla_bla],                          "bla_bla should be filtered"
      assert_equal '1', result[:every_other2],                "yearly attributes should be preserved"
      assert_equal "a repeating todo",  result[:description], "description should be preserved"
    end

  end

end