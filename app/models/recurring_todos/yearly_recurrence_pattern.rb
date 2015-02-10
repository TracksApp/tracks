module RecurringTodos

  class YearlyRecurrencePattern < AbstractRecurrencePattern

    def initialize(user)
      super user
    end

    def recurrence_selector
      get :recurrence_selector
    end

    def month_of_year
      get :every_other2
    end

    def every_x_day
      get :every_other1
    end

    def every_xth_day
      get :every_other3
    end

    def day_of_week
      get :every_count
    end

    def month_of_year2
      # if recurrence pattern is every xth day in a month, return month otherwise
      # return a default value
      get(:recurrence_selector) == 1 ? get(:every_other2) : Time.zone.now.month
    end

    def recurrence_pattern
      if self.recurrence_selector == 0
        I18n.t("todos.recurrence.pattern.every_year_on", :date => date_as_month_day)
      else
        I18n.t("todos.recurrence.pattern.every_year_on",
          :date => I18n.t("todos.recurrence.pattern.the_xth_day_of_month",
            :x => xth(every_xth_day),
            :day => day_of_week_as_text(day_of_week),
            :month => month_of_year_as_text(month_of_year)
          ))
      end
    end

    def validate
      super
      case recurrence_selector
      when 0 # 'yearly_every_x_day'
        validate_not_blank(month_of_year, "The month of the year may not be empty for recurrence setting")
        validate_not_blank(every_x_day, "The day of the month may not be empty for recurrence setting")
      when 1 # 'yearly_every_xth_day'
        validate_not_blank(month_of_year2, "The month of the year may not be empty for recurrence setting")
        validate_not_blank(every_xth_day, "The nth day of the month may not be empty for recurrence setting")
        validate_not_blank(day_of_week, "The day of the week may not be empty for recurrence setting")
      else
        raise "unexpected value of recurrence selector '#{recurrence_selector}'"
      end
    end

    def get_next_date(previous)
      start = determine_start(previous)
      month = get(:every_other2)

      case recurrence_selector
      when 0 # specific day of a specific month
        return get_specific_day_of_month(start, month)
      when 1 # relative weekday of a specific month
        return get_relative_weekday_of_month(start, month)
      end
      nil
    end

    private

    def date_as_month_day
      I18n.l(DateTime.new(Time.zone.now.year, month_of_year, every_x_day), :format => :month_day)
    end

    def get_specific_day_of_month(start, month)
      if start.month > month || (start.month == month && start.day >= every_x_day)
        # if there is no next month n and day m in this year, search in next
        # year
        start = Time.zone.local(start.year+1, month, 1)
      else
        # if there is a next month n, stay in this year
        start = Time.zone.local(start.year, month, 1)
      end
      Time.zone.local(start.year, month, every_x_day)
    end

    def get_relative_weekday_of_month(start, month)
      # if there is no next month n in this year, search in next year
      the_next = start.month > month ? Time.zone.local(start.year+1, month, 1) : start

      # get the xth day of the month
      the_next = get_xth_day_of_month(self.every_xth_day, day_of_week, month, the_next.year)

      # if the_next is before previous, we went back into the past, so try next
      # year
      the_next = get_xth_day_of_month(self.every_xth_day, day_of_week, month, start.year+1) if the_next <= start

      the_next
    end

  end
end
