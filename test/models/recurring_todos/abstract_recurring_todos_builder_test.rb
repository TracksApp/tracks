require_relative '../../test_helper'

module RecurringTodos

  class AbstractRecurringTodosBuilderTest < ActiveSupport::TestCase
    fixtures :users

    class TestRepeatPattern < AbstractRepeatPattern 
      def selector_key
        'test'
      end

      def valid_selector?(selector)
        true
      end
    end

    def setup
      @admin = users(:admin_user)
    end 

    def test_filter_attributes_should_throw_exception
      attributes = Tracks::AttributeHandler.new(@admin, {
        'recurring_period' => "daily",
        'description'      => "test",
        'tag_list'         => "tag, this, that",
        'context_name'     => "my new context",
        'daily_selector'   => 'daily_every_work_day', 
        'target'           => 'due_date',
        'show_always'      => true,
        'start_from'       => '01/01/01',
        'ends_on'          => 'no_end_date'
      })
  
      assert_raise(Exception, "should have exception since we are using abstract builder") do 
        builder = AbstractRecurringTodosBuilder.new(@admin, attributes, DailyRepeatPattern)
      end
    end  

    def test_tags_should_be_filled_or_empty_string
      # given attributes with filled tag_list
      attributes = {
        'recurring_period' => 'daily',
        'daily_selector'   => 'daily_every_work_day', 
        'tag_list' => "tag, this, that"
      }

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert_equal "tag, this, that", builder.attributes.get(:tag_list)

      # given attributes without tag_list
      attributes = {
        'recurring_period' => 'daily',
        'daily_selector'   => 'daily_every_work_day', 
      }

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert_equal "", builder.attributes.get(:tag_list)

      # given attributes with nil tag_list
      attributes = {
        'recurring_period' => 'daily',
        'daily_selector'   => 'daily_every_work_day', 
        'tag_list'         => nil
      }

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert_equal "", builder.attributes.get(:tag_list)

      # given attributes with empty tag_list ==> should be stripped
      attributes = {
        'recurring_period' => 'daily',
        'daily_selector'   => 'daily_every_work_day', 
        'tag_list'         => "    "
      }

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert_equal "", builder.attributes.get(:tag_list)
    end

    def test_tags_should_be_saved_on_create_and_update
      attributes = {
        'recurring_period'  => "daily",
        'description'       => "test",
        'tag_list'          => "tag, this, that",
        'context_name'      => "my new context",
        'daily_selector'    => 'daily_every_work_day', 
        'recurring_target'  => 'show_from_date',
        'show_always'       => true,
        'start_from'        => '01/01/01',
        'ends_on'           => 'no_end_date'
      }

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert builder.save, "it should be saved"
      assert_equal "tag, that, this", builder.saved_recurring_todo.tag_list, "tags should be saved"

      attributes['tag_list'] = ''  # clear tag_list

      builder = RecurringTodosBuilder.new(@admin, attributes)
      assert !builder.tag_list.present?, "tag list should not be present"
      assert builder.save, "it should be saved"
      assert_equal "", builder.saved_recurring_todo.tag_list, "tag list should be empty"

      # tags should be updated
      rt = builder.saved_recurring_todo
      attributes['tag_list'] = "bar, foo"
      updater = RecurringTodosBuilder.new(@admin, attributes)
      updater.update(rt)
      rt.reload
      assert_equal "bar, foo", rt.tag_list
    end

    def test_saved_should_raise_exception_on_validation_errors
      attributes = {
        'recurring_period' => "daily",
        'description'      => "test",
        'tag_list'         => "tag, this, that",
        'context_name'     => "my new context",
        'daily_selector'   => 'daily_every_work_day', 
        'recurring_target' => 'due_date',
        'show_always'      => true,
        'start_from'       => '01/01/01',
        'ends_on'          => 'no_end_date_error'   # invalid end_on value
      }

      # creating builder should not raise exception
      builder = RecurringTodosBuilder.new(@admin, attributes)
      builder.build

      assert !builder.recurring_todo.valid?, "model should have validation errors"

      assert !builder.save, "should not be able to save because of validation errors"
      assert_raise(Exception, "should have exception since there is no saved recurring todo"){ builder.saved_recurring_todo }
    end

    def test_map_removes_mapped_key
      attributes = Tracks::AttributeHandler.new(@admin, { :source => "value"})

      arp = WeeklyRecurringTodosBuilder.new(@admin, attributes)
      attributes = arp.map(attributes, :target, :source)

      assert_equal "value", attributes.get(:target)
      assert_nil attributes.get(:source)
      assert !attributes.key?(:source)
    end

    def test_get_selector_removes_selector_from_hash
      attributes = Tracks::AttributeHandler.new(@admin, { :selector => "weekly" })
      arp = WeeklyRecurringTodosBuilder.new(@admin, attributes)

      assert "weekly", arp.get_selector(:selector)
      assert !arp.attributes.key?(:selector)
    end

    def test_get_selector_raises_exception_when_missing_selector
      attributes = Tracks::AttributeHandler.new(@admin, { })
      arp = WeeklyRecurringTodosBuilder.new(@admin, attributes)

      assert_raise(Exception, "should raise exception when recurrence selector is missing"){ arp.get_selector(:selector) }
    end

  end

end