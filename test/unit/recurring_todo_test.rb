require File.dirname(__FILE__) + '/../test_helper'

class RecurringTodoTest < ActiveSupport::TestCase
  fixtures :todos, :users, :contexts, :preferences, :tags, :taggings, :recurring_todos

  def setup
    @every_day = RecurringTodo.find(1).reload
    @every_workday = RecurringTodo.find(2).reload
    @weekly_every_day = RecurringTodo.find(3).reload
    @monthly_every_last_friday = RecurringTodo.find(4).reload
    @yearly = RecurringTodo.find(5).reload

    @today = Time.now.utc
    @tomorrow = @today + 1.day
    @in_three_days = Time.now.utc + 3.days
    @in_four_days = @in_three_days + 1.day    # need a day after start_from

    @friday = Time.zone.local(2008,6,6)
    @saturday = Time.zone.local(2008,6,7)
    @sunday = Time.zone.local(2008,6,8)  # june 8, 2008 was a sunday
    @monday = Time.zone.local(2008,6,9)
    @tuesday = Time.zone.local(2008,6,10)
    @wednesday = Time.zone.local(2008,6,11)
    @thursday = Time.zone.local(2008,6,12)
  end
  
  def test_pattern_text
    assert_equal "every day", @every_day.recurrence_pattern
    assert_equal "on work days", @every_workday.recurrence_pattern
    assert_equal "every last Friday of every 2 months", @monthly_every_last_friday.recurrence_pattern
    assert_equal "every year on June 8", @yearly.recurrence_pattern
  end
 
  def test_daily_every_day
    # every_day should return todays date if there was no previous date
    due_date = @every_day.get_due_date(nil)
    # use strftime in compare, because milisec / secs could be different
    assert_equal @today.strftime("%d-%m-%y"), due_date.strftime("%d-%m-%y")

    # when the last todo was completed today, the next todo is due tomorrow
    due_date =@every_day.get_due_date(@today)
    assert_equal @tomorrow, due_date
        
    # do something every 14 days
    @every_day.every_other1=14
    due_date = @every_day.get_due_date(@today)
    assert_equal @today+14.days, due_date        
  end
  
  def test_daily_work_days
    assert_equal @monday, @every_workday.get_due_date(@friday)
    assert_equal @monday, @every_workday.get_due_date(@saturday)
    assert_equal @monday, @every_workday.get_due_date(@sunday)
    assert_equal @tuesday, @every_workday.get_due_date(@monday)
  end
  
  def test_show_from_date
    # assume that target due_date works fine, i.e. don't do the same tests over
    
    @every_day.target='show_from_date'
    # when recurrence is targeted on show_from, due date shoult remain nil
    assert_equal nil, @every_day.get_due_date(nil)
    assert_equal nil, @every_day.get_due_date(@today-3.days)
    
    # check show from get the next day
    assert_equal @today, @every_day.get_show_from_date(@today-1.days)
    assert_equal @today+1.day, @every_day.get_show_from_date(@today)
    
    @every_day.target='due_date'
    # when target on due_date, show_from is relative to due date unless show_always is true
    @every_day.show_always = true
    assert_equal nil, @every_day.get_show_from_date(@today-1.days)

    @every_day.show_always = false
    @every_day.show_from_delta=10
    assert_equal @today, @every_day.get_show_from_date(@today+9.days) #today+1+9-10
    
    # when show_from is 0, show_from is the same day it's due
    @every_day.show_from_delta=0
    assert_equal @every_day.get_due_date(@today+9.days), @every_day.get_show_from_date(@today+9.days)
    
    # when show_from is nil, show always (happend in tests)
    @every_day.show_from_delta=nil
    assert_equal nil, @every_day.get_show_from_date(@today+9.days)
    
    # TODO: show_from has no use case for daily pattern. Need to test on
    # weekly/monthly/yearly
  end
  
  def test_end_date_on_recurring_todo
    assert_equal true, @every_day.has_next_todo(@in_three_days)
    assert_equal true, @every_day.has_next_todo(@in_four_days)
    @every_day.end_date = @in_four_days
    @every_day.ends_on = 'ends_on_end_date'
    assert_equal false, @every_day.has_next_todo(@in_four_days)
  end
  
  def test_weekly_every_day_setters
    @weekly_every_day.every_day = '       '
    
    @weekly_every_day.weekly_return_sunday=('s')
    assert_equal 's      ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_monday=('m')
    assert_equal 'sm     ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_tuesday=('t')
    assert_equal 'smt    ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_wednesday=('w')
    assert_equal 'smtw   ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_thursday=('t')
    assert_equal 'smtwt  ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_friday=('f')
    assert_equal 'smtwtf ', @weekly_every_day.every_day
    @weekly_every_day.weekly_return_saturday=('s')
    assert_equal 'smtwtfs', @weekly_every_day.every_day
    
    # test remove
    @weekly_every_day.weekly_return_wednesday=(' ')
    assert_equal 'smt tfs', @weekly_every_day.every_day
  end
  
  def test_weekly_pattern
    assert_equal true, @weekly_every_day.has_next_todo(nil)
        
    due_date = @weekly_every_day.get_due_date(@sunday)
    assert_equal @monday, due_date
    
    # saturday is last day in week, so the next date should be sunday + n-1 weeks
    # n-1 because sunday is already in the next week
    @weekly_every_day.every_other1 = 3
    due_date = @weekly_every_day.get_due_date(@saturday)
    assert_equal @sunday + 2.weeks, due_date

    # remove tuesday and wednesday
    @weekly_every_day.weekly_return_tuesday=(' ')
    @weekly_every_day.weekly_return_wednesday=(' ')
    assert_equal 'sm  tfs', @weekly_every_day.every_day
    due_date = @weekly_every_day.get_due_date(@monday)
    assert_equal @thursday, due_date
    
    @weekly_every_day.every_other1 = 1
    @weekly_every_day.every_day = '  tw   '
    due_date = @weekly_every_day.get_due_date(@tuesday)
    assert_equal @wednesday, due_date    
    due_date = @weekly_every_day.get_due_date(@wednesday)
    assert_equal @tuesday+1.week, due_date    

    @weekly_every_day.every_day = '      s'
    due_date = @weekly_every_day.get_due_date(@sunday)
    assert_equal @saturday+1.week, due_date
  end
  
  def test_monthly_pattern
    due_date = @monthly_every_last_friday.get_due_date(@sunday)
    assert_equal Time.zone.local(2008,6,27), due_date
    
    friday_is_last_day_of_month = Time.zone.local(2008,10,31)
    due_date = @monthly_every_last_friday.get_due_date(friday_is_last_day_of_month-1.day )
    assert_equal friday_is_last_day_of_month , due_date
    
    @monthly_every_third_friday = @monthly_every_last_friday
    @monthly_every_third_friday.every_other3=3 #third
    due_date = @monthly_every_last_friday.get_due_date(@sunday) # june 8th 2008
    assert_equal Time.zone.local(2008, 6, 20), due_date
    # set date past third friday of this month
    due_date = @monthly_every_last_friday.get_due_date(Time.zone.local(2008,6,21)) # june 21th 2008
    assert_equal Time.zone.local(2008, 8, 15), due_date    # every 2 months, so aug
    
    @monthly = @monthly_every_last_friday
    @monthly.recurrence_selector=0
    @monthly.every_other1 = 8  # every 8th day of the month
    @monthly.every_other2 = 2  # every 2 months
    
    due_date = @monthly.get_due_date(@saturday) # june 7th
    assert_equal @sunday, due_date # june 8th
    
    due_date = @monthly.get_due_date(@sunday) # june 8th
    assert_equal Time.zone.local(2008,8,8), due_date # aug 8th
  end
  
  def test_yearly_pattern
    # beginning of same year
    due_date = @yearly.get_due_date(Time.zone.local(2008,2,10)) # feb 10th
    assert_equal @sunday, due_date # june 8th   
    
    # same month, previous date
    due_date = @yearly.get_due_date(@saturday) # june 7th
    show_from_date = @yearly.get_show_from_date(@saturday) # june 7th
    assert_equal @sunday, due_date # june 8th
    assert_equal @sunday-5.days, show_from_date

    # same month, day after
    due_date = @yearly.get_due_date(@monday) # june 9th
    assert_equal Time.zone.local(2009,6,8), due_date # june 8th next year
    # very overdue
    due_date = @yearly.get_due_date(@monday+5.months-2.days) # november 7
    assert_equal Time.zone.local(2009,6,8), due_date # june 8th next year
    
    @yearly.recurrence_selector = 1 
    @yearly.every_other3 = 2 # second
    @yearly.every_count = 3 # wednesday
    # beginning of same year
    due_date = @yearly.get_due_date(Time.zone.local(2008,2,10)) # feb 10th
    assert_equal Time.zone.local(2008,6,11), due_date # june 11th
    # same month, before second wednesday
    due_date = @yearly.get_due_date(@saturday) # june 7th
    assert_equal Time.zone.local(2008,6,11), due_date # june 11th
    # same month, after second wednesday
    due_date = @yearly.get_due_date(Time.zone.local(2008,6,12)) # june 7th
    assert_equal Time.zone.local(2009,6,10), due_date # june 10th
  end

  def test_next_todo_without_previous_todo
    # test handling of nil as previous
    #
    # start_from is way_back
    due_date1 = @yearly.get_due_date(nil) 
    due_date2 = @yearly.get_due_date(Time.now.utc + 1.day)
    assert_equal due_date1, due_date2

    # start_from is in the future
    @yearly.start_from = Time.now.utc + 1.week
    due_date1 = @yearly.get_due_date(nil)
    due_date2 = @yearly.get_due_date(Time.now.utc + 1.day)
    assert_equal due_date1, due_date2

    # start_from is nil
    @yearly.start_from = nil
    due_date1 = @yearly.get_due_date(nil)
    due_date2 = @yearly.get_due_date(Time.now.utc + 1.day)
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
    assert_equal @in_three_days, due_date
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
    
    this_year = Time.now.utc.year
    @yearly.start_from = Time.zone.local(this_year+1,6,12)
    due_date = @yearly.get_due_date(nil) 
    assert_equal due_date.year, this_year+2
  end
  
  def test_toggle_completion
    t = @yearly
    assert_equal :active, t.current_state
    t.toggle_completion!
    assert_equal :completed, t.current_state
    t.toggle_completion!
    assert_equal :active, t.current_state
  end
  
  def test_starred
    @yearly.tag_with("1, 2, starred")
    @yearly.tags.reload

    assert_equal true, @yearly.starred?
    assert_equal false, @weekly_every_day.starred?
    
    @yearly.toggle_star!
    assert_equal false, @yearly.starred?
    @yearly.toggle_star!
    assert_equal true, @yearly.starred?
  end
  
  def test_occurence_count
    @every_day.number_of_occurences = 2
    assert_equal true, @every_day.has_next_todo(@in_three_days)
    @every_day.inc_occurences
    assert_equal true, @every_day.has_next_todo(@in_three_days)
    @every_day.inc_occurences
    assert_equal false, @every_day.has_next_todo(@in_three_days)    
    
    # after completion, when you reactivate the recurring todo, the occurences
    # count should be reset
    assert_equal 2, @every_day.occurences_count
    @every_day.toggle_completion!
    @every_day.toggle_completion!
    assert_equal true, @every_day.has_next_todo(@in_three_days)
    assert_equal 0, @every_day.occurences_count
  end
  
end
