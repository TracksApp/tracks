require_relative '../../test_helper'

module RecurringTodos

  class WeeklyRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    def setup
      @admin = users(:admin_user)
    end 

    def test_every_x_week
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first

      assert_equal rt.every_other1, rt.pattern.every_x_week
    end

    def test_on_xday
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert rt.valid?, "should be valid at start: id= #{rt.id} --> #{rt.errors.full_messages}"

      rt.every_day = 'smtwtfs'
      %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
        assert rt.pattern.send("on_#{day}"), "on_#{day} should return true"
      end

      rt.every_day = 'smt tfs' # no wednesday
      assert !rt.pattern.on_wednesday, "wednesday should be false"
    end

    def test_validations
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert rt.valid?, "should be valid at start: #{rt.errors.full_messages}"

      rt.every_other1 = nil
      assert !rt.valid?, "missing evert_x_week should not be valid"

      rt.every_other1 = 1
      rt.every_day = '       '
      assert !rt.valid?, "missing selected days in every_day"
    end
    
    def test_pattern_text
      rt = @admin.recurring_todos.where(recurring_period: 'weekly').first
      assert_equal "every 2 weeks", rt.recurrence_pattern            

      rt.every_other1 = 1
      assert_equal "weekly", rt.recurrence_pattern            
    end

  end

end