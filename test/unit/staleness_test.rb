require_relative '../minimal_test_helper'
require_relative '../../lib/staleness'

FakeUser = Struct.new(:time, :prefs)
FakePrefs = Struct.new(:staleness_starts)
FakeTask = Struct.new(:due, :completed, :created_at) do
  def completed?
    self.completed
  end
end

class StalenessTest < Test::Unit::TestCase

  def now
    @now ||= Time.utc(2013, 2, 28, 0, 0, 0)
  end

  def day0
    @day0 ||= Time.utc(2013, 2, 27, 0, 0, 0)
  end

  def day24
    @day24 ||= Time.utc(2013, 2, 4, 0, 0, 0)
  end

  def day16
    @day16 ||= Time.utc(2013, 2, 12, 0, 0, 0)
  end

  def day8
    @day8 ||= Time.utc(2013, 2, 20, 0, 0, 0)
  end

  def fake_prefs
    @fake_prefs ||= FakePrefs.new(7)
  end

  def setup
    @current_user = FakeUser.new(now, fake_prefs)
  end

  def test_item_with_due_date_is_not_stale_ever
    todo = FakeTask.new(day24, false, now)
    assert_equal "", Staleness.days_stale(todo, @current_user)
  end

  def test_complete_item_is_not_stale
    todo = FakeTask.new(day16, true, day24)
    assert_equal "", Staleness.days_stale(todo, @current_user)
  end

  def test_young_item_is_not_stale
    todo = FakeTask.new(nil, false, now)
    assert_equal "", Staleness.days_stale(todo, @current_user)
  end

  def test_staleness_level_one
    todo = FakeTask.new(nil, false, day8)
    assert_equal " stale_l1", Staleness.days_stale(todo, @current_user)
  end

  def test_staleness_level_two
    todo = FakeTask.new(nil, false, day16)
    assert_equal " stale_l2", Staleness.days_stale(todo, @current_user)
  end

  def test_staleness_level_three
    todo = FakeTask.new(nil, false, day24)
    assert_equal " stale_l3", Staleness.days_stale(todo, @current_user)
  end
end
