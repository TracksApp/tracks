require_relative '../../test_helper'

module RecurringTodos

  class AbstractRepeatPatternTest < ActiveSupport::TestCase
    fixtures :users

    class TestRepeatPattern < AbstractRepeatPattern 
      def valid_selector?(selector)
        true
      end
    end

    def setup
      @admin = users(:admin_user)
    end 

    def test_map_removes_mapped_key
      attributes = { :source => "value"}

      arp = AbstractRepeatPattern.new(@admin, attributes)
      attributes = arp.map(attributes, :target, :source)

      assert_equal "value", attributes[:target]
      assert_nil attributes[:source]
      assert !attributes.key?(:source)
    end

    def test_get_selector_removes_selector_from_hash
      attributes = { :selector => "weekly" }
      arp = TestRepeatPattern.new(@admin, attributes)

      assert "weekly", arp.get_selector(:selector)
      assert !arp.attributes.key?(:selector)
    end

    def test_get_selector_raises_exception_when_missing_selector
      attributes = { }
      arp = TestRepeatPattern.new(@admin, attributes)

      assert_raise(Exception, "should raise exception when recurrence selector is missing"){ arp.get_selector(:selector) }
    end

  end

end