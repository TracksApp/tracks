class RecurringTodo < ActiveRecord::Base

  belongs_to :context
  belongs_to :project
  belongs_to :user

  has_many :todos

  named_scope :active, :conditions => { :state => 'active'}
  named_scope :completed, :conditions => { :state => 'completed'}

  attr_protected :user

  include AASM
  aasm_column :state
  aasm_initial_state :active

  aasm_state :active, :enter => Proc.new { |t| t.occurences_count = 0 }
  aasm_state :completed, :enter => Proc.new { |t| t.completed_at = Time.zone.now }, :exit => Proc.new { |t| t.completed_at = nil }

  aasm_event :complete do
    transitions :to => :completed, :from => [:active]
  end

  aasm_event :activate do
    transitions :to => :active, :from => [:completed]
  end

  validates_presence_of :description
  validates_presence_of :recurring_period
  validates_presence_of :target
  validates_presence_of :ends_on
  validates_presence_of :context

  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true

  validate :period_specific_validations
  validate :starts_and_ends_on_validations
  validate :set_recurrence_on_validations

  def period_specific_validations
    if %W[daily weekly monthly yearly].include?(recurring_period)
      self.send("validate_#{recurring_period}")
    else
      errors.add(:recurring_period, "is an unknown recurrence pattern: '#{self.recurring_period}'")
    end
  end

  def validate_daily
    if (!only_work_days) && (daily_every_x_days.nil? || daily_every_x_days.blank?)
      errors.add_to_base("Every other nth day may not be empty for recurrence setting")
    end
  end

  def validate_weekly
    if weekly_every_x_week.nil? || weekly_every_x_week.blank?
      errors.add_to_base("Every other nth week may not be empty for recurrence setting")
    end
    something_set = false
    %w{sunday monday tuesday wednesday thursday friday saturday}.each do |day|
      something_set ||= self.send("on_#{day}")
    end
    errors.add_to_base("You must specify at least one day on which the todo recurs") if !something_set
  end

  def validate_monthly
    case recurrence_selector
    when 0 # 'monthly_every_x_day'
      errors.add_to_base("The day of the month may not be empty for recurrence setting") if monthly_every_x_day.nil? || monthly_every_x_day.blank?
      errors.add_to_base("Every other nth month may not be empty for recurrence setting") if monthly_every_x_month.nil? || monthly_every_x_month.blank?
    when 1 # 'monthly_every_xth_day'
      errors.add_to_base("Every other nth month may not be empty for recurrence setting") if monthly_every_x_month2.nil? || monthly_every_x_month2.blank?
      errors.add_to_base("The nth day of the month may not be empty for recurrence setting") if monthly_every_xth_day.nil? || monthly_every_xth_day.blank?
      errors.add_to_base("The day of the month may not be empty for recurrence setting") if monthly_day_of_week.nil? || monthly_day_of_week.blank?
    else
      raise Exception.new, "unexpected value of recurrence selector '#{self.recurrence_selector}'"
    end
  end

  def validate_yearly
    case recurrence_selector
    when 0 # 'yearly_every_x_day'
      errors.add_to_base("The month of the year may not be empty for recurrence setting") if yearly_month_of_year.nil? || yearly_month_of_year.blank?
      errors.add_to_base("The day of the month may not be empty for recurrence setting") if yearly_every_x_day.nil? || yearly_every_x_day.blank?
    when 1 # 'yearly_every_xth_day'
      errors.add_to_base("The month of the year may not be empty for recurrence setting") if yearly_month_of_year2.nil? || yearly_month_of_year2.blank?
      errors.add_to_base("The nth day of the month may not be empty for recurrence setting") if yearly_every_xth_day.nil? || yearly_every_xth_day.blank?
      errors.add_to_base("The day of the week may not be empty for recurrence setting") if yearly_day_of_week.nil? || yearly_day_of_week.blank?
    else
      raise Exception.new, "unexpected value of recurrence selector '#{self.recurrence_selector}'"
    end
  end

  def starts_and_ends_on_validations
    errors.add_to_base("The start date needs to be filled in") if start_from.nil? || start_from.blank?
    case self.ends_on
    when 'ends_on_number_of_times'
      errors.add_to_base("The number of recurrences needs to be filled in for 'Ends on'") if number_of_occurences.nil? || number_of_occurences.blank?
    when "ends_on_end_date"
      errors.add_to_base("The end date needs to be filled in for 'Ends on'") if end_date.nil? || end_date.blank?
    else
      errors.add_to_base("The end of the recurrence is not selected") unless ends_on == "no_end_date"
    end
  end

  def set_recurrence_on_validations
    # show always or x days before due date. x not null
    case self.target
    when 'show_from_date'
      # no validations
    when 'due_date'
      errors.add_to_base("Please select when to show the action") if show_always.nil?
      unless show_always
        errors.add_to_base("Please fill in the number of days to show the todo before the due date") if show_from_delta.nil? || show_from_delta.blank?
      end
    else
      raise Exception.new, "unexpected value of recurrence target selector '#{self.recurrence_target}'"
    end
  end

  # the following recurrence patterns can be stored:
  #
  # daily todos - recurrence_period = 'daily'
  #   every nth day - nth stored in every_other1
  #   every work day - only_work_days = true
  #   tracks will choose between both options using only_work_days
  # weekly todos - recurrence_period = 'weekly'
  #   every nth week on a specific day -
  #      nth stored in every_other1 and the specific day is stored in every_day
  # monthly todos - recurrence_period = 'monthly'
  #   every day x of nth month - x stored in every_other1 and nth is stored in every_other2
  #   the xth y-day of every nth month (the forth tuesday of every 2 months) -
  #      x stored in every_other3, y stored in every_count, nth stored in every_other2
  #   choosing between both options is done on recurrence_selector where 0 is
  #   for first type and 1 for second type
  # yearly todos - recurrence_period = 'yearly'
  #   every day x of month y - x is stored in every_other1, y is stored in every_other2
  #   the x-th day y of month z (the forth tuesday of september) -
  #     x is stored in every_other3, y is stored in every_count, z is stored in every_other2
  #   choosing between both options is done on recurrence_selector where 0 is
  #   for first type and 1 for second type

  # DAILY

  def daily_selector=(selector)
    case selector
    when 'daily_every_x_day'
      self.only_work_days = false
    when 'daily_every_work_day'
      self.only_work_days = true
    else
      raise Exception.new, "unknown daily recurrence pattern: '#{selector}'"
    end
  end

  def daily_every_x_days=(x)
    if recurring_period=='daily'
      self.every_other1 = x
    end
  end

  def daily_every_x_days
    return self.every_other1
  end

  # WEEKLY

  def weekly_every_x_week=(x)
    self.every_other1 = x if recurring_period=='weekly'
  end

  def weekly_every_x_week
    return self.every_other1
  end

  def switch_week_day (day, position)
    if self.every_day.nil?
      self.every_day='       '
    end
    self.every_day = self.every_day[0,position] + day + self.every_day[position+1,self.every_day.length]
  end

  def weekly_return_monday=(selector)
    switch_week_day(selector,1) if recurring_period=='weekly'
  end

  def weekly_return_tuesday=(selector)
    switch_week_day(selector,2) if recurring_period=='weekly'
  end

  def weekly_return_wednesday=(selector)
    switch_week_day(selector,3) if recurring_period=='weekly'
  end

  def weekly_return_thursday=(selector)
    switch_week_day(selector,4) if recurring_period=='weekly'
  end

  def weekly_return_friday=(selector)
    switch_week_day(selector,5) if recurring_period=='weekly'
  end

  def weekly_return_saturday=(selector)
    switch_week_day(selector,6) if recurring_period=='weekly'
  end

  def weekly_return_sunday=(selector)
    switch_week_day(selector,0) if recurring_period=='weekly'
  end

  def on_xday(n)
    unless self.every_day.nil?
      return self.every_day[n,1] == ' ' ? false : true
    else
      return false
    end
  end

  def on_monday
    return on_xday(1)
  end

  def on_tuesday
    return on_xday(2)
  end

  def on_wednesday
    return on_xday(3)
  end

  def on_thursday
    return on_xday(4)
  end

  def on_friday
    return on_xday(5)
  end

  def on_saturday
    return on_xday(6)
  end

  def on_sunday
    return on_xday(0)
  end

  # MONTHLY

  def monthly_selector=(selector)
    if recurring_period=='monthly'
      self.recurrence_selector= (selector=='monthly_every_x_day')? 0 : 1
    end
  end

  def monthly_every_x_day=(x)
    self.every_other1 = x if recurring_period=='monthly'
  end

  def monthly_every_x_day
    return self.every_other1
  end

  def is_monthly_every_x_day
    return self.recurrence_selector == 0 if recurring_period == 'monthly'
    return false
  end

  def is_monthly_every_xth_day
    return self.recurrence_selector == 1 if recurring_period == 'monthly'
    return false
  end

  def monthly_every_x_month=(x)
    self.every_other2 = x if recurring_period=='monthly' && recurrence_selector == 0
  end

  def monthly_every_x_month
    # in case monthly pattern is every day x, return every_other2 otherwise
    # return a default value
    if self.recurrence_selector == 0
      return self.every_other2
    else
      return 1
    end
  end

  def monthly_every_x_month2=(x)
    self.every_other2 = x if recurring_period=='monthly' && recurrence_selector == 1
  end

  def monthly_every_x_month2
    # in case monthly pattern is every xth day, return every_other2 otherwise
    # return a default value
    if self.recurrence_selector == 1
      return self.every_other2
    else
      return 1
    end
  end

  def monthly_every_xth_day=(x)
    self.every_other3 = x if recurring_period=='monthly'
  end

  def monthly_every_xth_day(default=nil)
    return self.every_other3 unless self.every_other3.nil?
    return default
  end

  def monthly_day_of_week=(dow)
    self.every_count = dow if recurring_period=='monthly'
  end

  def monthly_day_of_week
    return self.every_count
  end

  # YEARLY

  def yearly_selector=(selector)
    if recurring_period=='yearly'
      self.recurrence_selector = (selector=='yearly_every_x_day') ? 0 : 1
    end
  end

  def yearly_month_of_year=(moy)
    self.every_other2 = moy if self.recurring_period=='yearly'  && self.recurrence_selector == 0
  end

  def yearly_month_of_year
    # if recurrence pattern is every x day in a month, return month otherwise
    # return a default value
    if self.recurrence_selector == 0
      return self.every_other2
    else
      return Time.zone.now.month
    end
  end

  def yearly_month_of_year2=(moy)
    self.every_other2 = moy if self.recurring_period=='yearly' && self.recurrence_selector == 1
  end

  def yearly_month_of_year2
    # if recurrence pattern is every xth day in a month, return month otherwise
    # return a default value
    if self.recurrence_selector == 1
      return self.every_other2
    else
      return Time.zone.now.month
    end
  end

  def yearly_every_x_day=(x)
    self.every_other1 = x if recurring_period=='yearly'
  end

  def yearly_every_x_day
    return self.every_other1
  end

  def yearly_every_xth_day=(x)
    self.every_other3 = x if recurring_period=='yearly'
  end

  def yearly_every_xth_day
    return self.every_other3
  end

  def yearly_day_of_week=(dow)
    self.every_count=dow if recurring_period=='yearly'
  end

  def yearly_day_of_week
    return self.every_count
  end

  # target

  def recurring_target=(t)
    self.target = t
  end

  def recurring_target_as_text
    case self.target
    when 'due_date'
      return I18n.t("todos.recurrence.pattern.due")
    when 'show_from_date'
      return I18n.t("todos.recurrence.pattern.show")
    else
      raise Exception.new, "unexpected value of recurrence target '#{self.target}'"
    end
  end

  def recurring_show_days_before=(days)
    self.show_from_delta=days
  end

  def recurring_show_always=(value)
    self.show_always=value
  end

  def recurrence_pattern
    return "invalid repeat pattern" if every_other1.nil?
    case recurring_period
    when 'daily'
      if only_work_days
        return I18n.t("todos.recurrence.pattern.on_work_days")
      else
        if every_other1 > 1
          return I18n.t("todos.recurrence.pattern.every_n", :n => every_other1) + " " + I18n.t("common.days")
        else
          return I18n.t("todos.recurrence.pattern.every_day")
        end
      end
    when 'weekly'
      if every_other1 > 1
        return I18n.t("todos.recurrence.pattern.every_n", :n => every_other1) + " " + I18n.t("common.weeks")
      else
        return I18n.t('todos.recurrence.pattern.weekly')
      end
    when 'monthly'
      return "invalid repeat pattern" if every_other2.nil?
      if self.recurrence_selector == 0
        on_day = " " + I18n.t('todos.recurrence.pattern.on_day_n', :n => self.every_other1)
        if self.every_other2>1
          return I18n.t("todos.recurrence.pattern.every_n", :n => self.every_other2) + " " + I18n.t('common.months') + on_day
        else
          return I18n.t("todos.recurrence.pattern.every_month") + on_day
        end
      else
        if self.every_other2>1
          n_months = "#{self.every_other2} " + I18n.t('common.months')
        else
          n_months = I18n.t('common.month')
        end
        return I18n.t('todos.recurrence.pattern.every_xth_day_of_every_n_months',
          :x => self.xth, :day => self.day_of_week, :n_months => n_months)
      end
    when 'yearly'
      if self.recurrence_selector == 0
        return I18n.t("todos.recurrence.pattern.every_year_on",
          :date => I18n.l(DateTime.new(Time.zone.now.year, self.every_other2, self.every_other1), :format => :month_day))
      else
        return I18n.t("todos.recurrence.pattern.every_year_on",
          :date => I18n.t("todos.recurrence.pattern.the_xth_day_of_month", :x => self.xth, :day => self.day_of_week, :month => self.month_of_year))
      end
    else
      return 'unknown recurrence pattern: period unknown'
    end
  end

  def xth
    xth_day = [
      I18n.t('todos.recurrence.pattern.first'),I18n.t('todos.recurrence.pattern.second'),I18n.t('todos.recurrence.pattern.third'),
      I18n.t('todos.recurrence.pattern.fourth'),I18n.t('todos.recurrence.pattern.last')]
    return self.every_other3.nil? ? '??' : xth_day[self.every_other3-1]
  end

  def day_of_week
    return (self.every_count.nil? ? '??' : I18n.t('todos.recurrence.pattern.day_names')[self.every_count])
  end

  def month_of_year
    return self.every_other2.nil? ? '??' : I18n.t('todos.recurrence.pattern.month_names')[self.every_other2]
  end

  def starred?
    return has_tag?(Todo::STARRED_TAG_NAME)
  end

  def has_tag?(tag_name)
    return self.tags.any? {|tag| tag.name == tag_name}
  end

  def get_due_date(previous)
    case self.target
    when 'due_date'
      return get_next_date(previous)
    when 'show_from_date'
      # so leave due date empty
      return nil
    else
      raise Exception.new, "unexpected value of recurrence target '#{self.target}'"
    end
  end

  def get_show_from_date(previous)
    case self.target
    when 'due_date'
      # so set show from date relative to due date unless show_always is true or show_from_delta is nil
      if self.show_always? or self.show_from_delta.nil?
        nil
      else
        get_due_date(previous) - self.show_from_delta.days
      end
    when 'show_from_date'
      # Leave due date empty
      return get_next_date(previous)
    else
      raise Exception.new, "unexpected value of recurrence target '#{self.target}'"
    end
  end

  def get_next_date(previous)
    case self.recurring_period
    when 'daily'
      return get_daily_date(previous)
    when 'weekly'
      return get_weekly_date(previous)
    when 'monthly'
      return get_monthly_date(previous)
    when 'yearly'
      return get_yearly_date(previous)
    else
      raise Exception.new, "unknown recurrence pattern: '#{self.recurring_period}'"
    end
  end

  def get_daily_date(previous)
    # previous is the due date of the previous todo or it is the completed_at
    # date when the completed_at date is after due_date (i.e. you did not make
    # the due date in time)
    #
    # assumes self.recurring_period == 'daily'

    start = determine_start(previous, 1.day)

    if self.only_work_days
      return start + 2.day if start.wday() == 6 # saturday
      return start + 1.day if start.wday() == 0 # sunday
      return start
    else # every nth day; n = every_other1
      # if there was no previous todo, do not add n: the first todo starts on
      # today or on start_from
      return previous == nil ? start : start+every_other1.day-1.day
    end
  end

  def get_weekly_date(previous)
    # determine start
    if previous == nil
      start = self.start_from.nil? ? Time.zone.now : self.start_from
    else
      start = previous + 1.day
      if start.wday() == 0
        # we went to a new week , go to the nth next week and find first match
        # that week. Note that we already went into the next week, so -1
        start += (self.every_other1-1).week
      end
      unless self.start_from.nil?
        # check if the start_from date is later than previous. If so, use
        # start_from as start to search for next date
        start = self.start_from if self.start_from > previous
      end
    end

    # check if there are any days left this week for the next todo
    start.wday().upto 6 do |i|
      return start + (i-start.wday()).days unless self.every_day[i,1] == ' '
    end

    # we did not find anything this week, so check the nth next, starting from
    # sunday
    start = start + self.every_other1.week - (start.wday()).days

    # check if there are any days left this week for the next todo
    start.wday().upto 6 do |i|
      return start + (i-start.wday()).days unless self.every_day[i,1] == ' '
    end

    raise Exception.new, "unable to find next weekly date (#{self.every_day})"
  end

  def get_monthly_date(previous)

    start = determine_start(previous)
    day = self.every_other1
    n = self.every_other2

    case self.recurrence_selector
    when 0 # specific day of the month
      if start.mday >= day
        # there is no next day n in this month, search in next month
        #
        #  start += n.months
        #
        # The above seems to not work. Fiddle with timezone. Looks like we hit a
        # bug in rails here where 2008-12-01 +0100 plus 1.month becomes
        # 2008-12-31 +0100. For now, just calculate in UTC and convert back to
        # local timezone.
        #
        #  TODO: recheck if future rails versions have this problem too
        start = Time.utc(start.year, start.month, start.day)+n.months
        start = Time.zone.local(start.year, start.month, start.day)

        # go back to day
      end
      return Time.zone.local(start.year, start.month, day)

    when 1 # relative weekday of a month
      the_next = get_xth_day_of_month(self.every_other3, self.every_count, start.month, start.year)
      if the_next.nil? || the_next <= start
        # the nth day is already passed in this month, go to next month and try
        # again

        # fiddle with timezone. Looks like we hit a bug in rails here where
        # 2008-12-01 +0100 plus 1.month becomes 2008-12-31 +0100. For now, just
        # calculate in UTC and convert back to local timezone.
        #  TODO: recheck if future rails versions have this problem too
        the_next = Time.utc(the_next.year, the_next.month, the_next.day)+n.months
        the_next = Time.zone.local(the_next.year, the_next.month, the_next.day)

        # TODO: if there is still no match, start will be set to nil. if we ever
        # support 5th day of the month, we need to handle this case
        the_next = get_xth_day_of_month(self.every_other3, self.every_count, the_next.month, the_next.year)
      end
      return the_next
    else
      raise Exception.new, "unknown monthly recurrence selection (#{self.recurrence_selector})"
    end
    return nil
  end

  def get_xth_day_of_month(x, weekday, month, year)
    if x == 5
      # last -> count backwards. use UTC to avoid strange timezone oddities
      # where last_day -= 1.day seems to shift tz+0100 to tz+0000
      last_day = Time.utc(year, month, Time.days_in_month(month))
      while last_day.wday != weekday
        last_day -= 1.day
      end
      # convert back to local timezone
      return Time.zone.local(last_day.year, last_day.month, last_day.day)
    else
      # 1-4th -> count upwards last -> count backwards. use UTC to avoid strange
      # timezone oddities where last_day -= 1.day seems to shift tz+0100 to
      # tz+0000
      start = Time.utc(year,month,1)
      n = x
      while n > 0
        while start.wday() != weekday
          start+= 1.day
        end
        n -= 1
        start += 1.day unless n==0
      end
      # convert back to local timezone
      return Time.zone.local(start.year, start.month, start.day)
    end
  end

  def get_yearly_date(previous)
    start = determine_start(previous)
    day = self.every_other1
    month = self.every_other2

    case self.recurrence_selector
    when 0 # specific day of a specific month
      if start.month > month || (start.month == month && start.day >= day)
        # if there is no next month n and day m in this year, search in next
        # year
        start = Time.zone.local(start.year+1, month, 1)
      else
        # if there is a next month n, stay in this year
        start = Time.zone.local(start.year, month, 1)
      end
      return Time.zone.local(start.year, month, day)

    when 1 # relative weekday of a specific month
      # if there is no next month n in this year, search in next year
      the_next = start.month > month ? Time.zone.local(start.year+1, month, 1) : start

      # get the xth day of the month
      the_next = get_xth_day_of_month(self.every_other3, self.every_count, month, the_next.year)

      # if the_next is before previous, we went back into the past, so try next
      # year
      the_next = get_xth_day_of_month(self.every_other3, self.every_count, month, start.year+1) if the_next <= start

      return the_next
    else
      raise Exception.new, "unknown monthly recurrence selection (#{self.recurrence_selector})"
    end
    return nil
  end

  def has_next_todo(previous)
    unless self.number_of_occurences.nil?
      return self.occurences_count < self.number_of_occurences
    else
      if self.end_date.nil? || self.ends_on == 'no_end_date'
        return true
      else
        case self.target
        when 'due_date'
          return get_due_date(previous) <= self.end_date
        when 'show_from_date'
          return get_show_from_date(previous) <= self.end_date
        else
          raise Exception.new, "unexpected value of recurrence target '#{self.target}'"
        end
      end
    end
  end

  def toggle_completion!
    return completed? ? activate! : complete!
  end

  def toggle_star!
    if starred?
      _remove_tags Todo::STARRED_TAG_NAME
      tags.reload
    else
      _add_tags(Todo::STARRED_TAG_NAME)
      tags.reload
    end
    starred?
  end

  def remove_from_project!
    self.project = nil
    self.save
  end

  def clear_todos_association
    unless todos.nil?
      self.todos.each do |t|
        t.recurring_todo = nil
        t.save
      end
    end
  end

  def inc_occurences
    self.occurences_count += 1
    self.save
  end

  protected

  # Determine start date to calculate next date for recurring todo
  # offset needs to be 1.day for daily patterns
  def determine_start(previous, offset=0.day)

    if previous.nil?
      start = self.start_from.nil? ? Time.zone.now : self.start_from
      # skip to present
      start = Time.zone.now if Time.zone.now > start
    else
      start = previous + offset

      # check if the start_from date is later than previous. If so, use
      # start_from as start to search for next date
      start = self.start_from if ( self.start_from && self.start_from > previous )
    end

    return start
  end

end
