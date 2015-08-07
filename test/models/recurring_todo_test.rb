require 'test_helper'

class RecurringTodoTest < ActiveSupport::TestCase

  def setup
    @every_day = recurring_todos(:call_bill_gates_every_day)
    @every_workday = recurring_todos(:call_bill_gates_every_workday)
    @weekly_every_day = recurring_todos(:call_bill_gates_every_week)
    @every_week = @weekly_every_day
    @monthly_every_last_friday = recurring_todos(:check_with_bill_every_last_friday_of_month)
    @every_month = @monthly_every_last_friday
    @yearly = recurring_todos(:birthday_reinier)

    @today = Time.zone.now
    @tomorrow = @today + 1.day
    @in_three_days = @today + 3.days
    @in_four_days = @in_three_days + 1.day    # need a day after start_from

    @friday = Time.zone.local(2008,6,6)
    @saturday = Time.zone.local(2008,6,7)
    @sunday = Time.zone.local(2008,6,8)  # june 8, 2008 was a sunday
    @monday = Time.zone.local(2008,6,9)
    @tuesday = Time.zone.local(2008,6,10)
    @wednesday = Time.zone.local(2008,6,11)
    @thursday = Time.zone.local(2008,6,12)
  end

  def test_show_from_date
    # assume that target due_date works fine, i.e. don't do the same tests over

    @every_day.target='show_from_date'
    # when recurrence is targeted on show_from, due date should remain nil
    assert_equal nil, @every_day.get_due_date(nil)
    assert_equal nil, @every_day.get_due_date(@today-3.days)

    # check show from get the next day
    assert_equal_dmy @today, @every_day.get_show_from_date(@today-1.days)
    assert_equal @today+1.day, @every_day.get_show_from_date(@today)

    @every_day.target='due_date'
    # when target on due_date, show_from is relative to due date unless show_always is true
    @every_day.show_always = true
    assert_equal nil, @every_day.get_show_from_date(@today-1.days)

    @every_day.show_always = false
    @every_day.show_from_delta=10
    assert_equal_dmy @today, @every_day.get_show_from_date(@today+9.days) #today+1+9-10

    # when show_from is 0, show_from is the same day it's due
    @every_day.show_from_delta=0
    assert_equal @every_day.get_due_date(@today+9.days), @every_day.get_show_from_date(@today+9.days)

    # when show_from is nil, show always (happend in tests)
    @every_day.show_from_delta=nil
    assert_equal nil, @every_day.get_show_from_date(@today+9.days)

    # TODO: show_from has no use case for daily pattern. Need to test on
    # weekly/monthly/yearly
  end

  def test_next_todo_without_previous_todo
    # test handling of nil as previous
    #
    # start_from is way_back
    due_date1 = @yearly.get_due_date(nil)
    due_date2 = @yearly.get_due_date(Time.zone.now + 1.day)
    assert_equal due_date1, due_date2

    # start_from is in the future
    @yearly.start_from = Time.zone.now + 1.week
    due_date1 = @yearly.get_due_date(nil)
    due_date2 = @yearly.get_due_date(Time.zone.now + 1.day)
    assert_equal due_date1, due_date2

    # start_from is nil
    @yearly.start_from = nil
    due_date1 = @yearly.get_due_date(nil)
    due_date2 = @yearly.get_due_date(Time.zone.now + 1.day)
    assert_equal due_date1, due_date2
  end

  def test_last_sunday_of_march
    @yearly.recurrence_selector = 1
    @yearly.every_other2 = 3 # march
    @yearly.every_other3 = 5 # last
    @yearly.every_count = 0 # sunday
    due_date = @yearly.get_due_date(Time.zone.local(2008,10,1)) # oct 1st
    assert_equal Time.zone.local(2009,3,29), due_date # march 29th
  end

  def test_start_from_in_future
    # every_day should return start_day if it is in the future
    @every_day.start_from = @in_three_days
    due_date = @every_day.get_due_date(nil)
    assert_equal @in_three_days.to_s(:db), due_date.to_s(:db)
    due_date = @every_day.get_due_date(@tomorrow)
    assert_equal @in_three_days, due_date

    # if we give a date in the future for the previous todo, the next to do
    # should be based on that future date.
    due_date = @every_day.get_due_date(@in_four_days)
    assert_equal @in_four_days+1.day, due_date

    @weekly_every_day.start_from = Time.zone.local(2020,1,1)
    assert_equal Time.zone.local(2020,1,1), @weekly_every_day.get_due_date(nil)
    assert_equal Time.zone.local(2020,1,1), @weekly_every_day.get_due_date(Time.zone.local(2019,10,1))
    assert_equal Time.zone.local(2020,1,10), @weekly_every_day.get_due_date(Time.zone.local(2020,1,9))

    @monthly_every_last_friday.start_from = Time.zone.local(2020,1,1)
    assert_equal Time.zone.local(2020,1,31), @monthly_every_last_friday.get_due_date(nil) # last friday of jan
    assert_equal Time.zone.local(2020,1,31), @monthly_every_last_friday.get_due_date(Time.zone.local(2019,12,1)) # last friday of jan
    assert_equal Time.zone.local(2020,2,28), @monthly_every_last_friday.get_due_date(Time.zone.local(2020,2,1)) # last friday of feb

    # start from after june 8th 2008
    @yearly.start_from = Time.zone.local(2020,6,12)
    assert_equal Time.zone.local(2021,6,8), @yearly.get_due_date(nil) # jun 8th next year
    assert_equal Time.zone.local(2021,6,8), @yearly.get_due_date(Time.zone.local(2019,6,1)) # also next year
    assert_equal Time.zone.local(2021,6,8), @yearly.get_due_date(Time.zone.local(2020,6,15)) # also next year

    this_year = Time.zone.now.utc.year
    @yearly.start_from = Time.zone.local(this_year+1,6,12)
    due_date = @yearly.get_due_date(nil)
    assert_equal due_date.year, this_year+2
  end

  def test_toggle_completion
    assert @yearly.active?
    assert @yearly.toggle_completion!, "toggle of completion should succeed"
    assert @yearly.completed?

    # entering completed state should set completed_at
    assert !@yearly.completed_at.nil?

    assert @yearly.toggle_completion!
    assert @yearly.active?

    # re-entering active state should clear completed_at
    assert @yearly.completed_at.nil?
  end

  def test_starred
    @yearly.tag_with("1, 2, starred")
    @yearly.tags.reload

    assert @yearly.starred?
    assert !@weekly_every_day.starred?

    @yearly.toggle_star!
    assert !@yearly.starred?
    @yearly.toggle_star!
    assert @yearly.starred?
  end

  def test_occurrence_count
    @every_day.number_of_occurrences = 2
    assert_equal true, @every_day.continues_recurring?(@in_three_days)
    @every_day.increment_occurrences
    assert_equal true, @every_day.continues_recurring?(@in_three_days)
    @every_day.increment_occurrences
    assert_equal false, @every_day.continues_recurring?(@in_three_days)

    # after completion, when you reactivate the recurring todo, the occurrences
    # count should be reset
    assert_equal 2, @every_day.occurrences_count
    assert @every_day.toggle_completion!
    assert @every_day.toggle_completion!

    assert_equal true, @every_day.continues_recurring?(@in_three_days)
    assert_equal 0, @every_day.occurrences_count
  end
end
