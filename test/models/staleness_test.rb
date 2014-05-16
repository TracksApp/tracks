require 'minimal_test_helper'
require_relative '../../lib/staleness'
require_relative '../../lib/user_time'

class StalenessTest < Minitest::Test
  include ActiveSupport::Testing::TimeHelpers

  FakePrefs = Struct.new(:time_zone)
  FakeUser = Struct.new(:time) do
    def prefs
      @prefs ||= FakePrefs.new("UTC")
    end
  end

  FakeTask = Struct.new(:due, :completed, :created_at) do
    def completed?
      self.completed
    end

  end

  def now
    @now ||= Time.utc(2013, 2, 28, 0, 0, 0)
  end

  def after_now
    @after_now ||= Time.utc(2013, 3, 1, 0, 0, 0)
  end

  def day16
    @day16 ||= Time.utc(2013, 2, 12, 0, 0, 0)
  end

  def day8
    @day8 ||= Time.utc(2013, 2, 20, 0, 0, 0)
  end

  def setup
    @current_user = FakeUser.new(now)
    travel_to Time.utc(2013,02,28)
  end

  def teardown
    travel_back
  end

  def test_item_with_due_date_is_not_stale_ever
    todo = FakeTask.new(now, false, day8)
    assert_equal 0, Staleness.days_stale(todo, @current_user)
  end

  def test_complete_item_is_not_stale
    todo = FakeTask.new(day8, true, day16)
    assert_equal 0, Staleness.days_stale(todo, @current_user)
  end

  def test_created_at_after_current_time_is_not_stale
    todo = FakeTask.new(nil, false, after_now)
    assert_equal 0, Staleness.days_stale(todo, @current_user)
  end

  def test_young_item_is_not_stale
    todo = FakeTask.new(nil, false, now)
    assert_equal 0, Staleness.days_stale(todo, @current_user)
  end

  def test_todo_staleness_calculation
    todo = FakeTask.new(nil, false, day8)
    assert_equal 8, Staleness.days_stale(todo, @current_user)
  end
end
