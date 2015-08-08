module RecurringTodos

  class MonthlyRecurrencePattern < AbstractRecurrencePattern

    def initialize(user)
      super user
    end

    def recurrence_selector
      get :recurrence_selector
    end

    def every_x_day?
      get(:recurrence_selector) == 0
    end

    def every_x_day
      get(:every_other1)
    end

    def every_xth_day?
      get(:recurrence_selector) == 1
    end

    def every_x_month
      # in case monthly pattern is every day x, return every_other2 otherwise
      # return a default value
      get(:recurrence_selector) == 0 ? get(:every_other2) : 1
    end

    def every_x_month2
      # in case monthly pattern is every xth day, return every_other2 otherwise
      # return a default value
      get(:recurrence_selector) == 1 ? get(:every_other2) : 1
    end

    def every_xth_day(default=nil)
      get(:every_other3) || default
    end

    def day_of_week
      get :every_count
    end

    def recurrence_pattern
      if recurrence_selector == 0
        recurrence_pattern_for_specific_day
      else
        recurrence_pattern_for_relative_day_in_month
      end
    end

    def validate
      super

      case recurrence_selector
      when 0 # 'monthly_every_x_day'
        validate_not_blank(every_x_month, "Every other nth month may not be empty for recurrence setting")
      when 1 # 'monthly_every_xth_day'
        validate_not_blank(every_x_month2, "Every other nth month may not be empty for recurrence setting")
        validate_not_blank(day_of_week, "The day of the month may not be empty for recurrence setting")
      else
        raise Exception.new, "unexpected value of recurrence selector '#{recurrence_selector}'"
      end
    end

    def get_next_date(previous)
      start = determine_start(previous)
      n = get(:every_other2)

      case recurrence_selector
      when 0 # specific day of the month
        return find_specific_day_of_month(previous, start, n)
      when 1 # relative weekday of a month
        return find_relative_day_of_month(start, n)
      end
      nil
    end

    private

    def find_specific_day_of_month(previous, start, n)
      if (previous && start.mday >= every_x_day) || (previous.nil? && start.mday > every_x_day)
        # there is no next day n in this month, search in next month
        start += n.months
      end
      start.in_time_zone.change(day: every_x_day)
    end

    def find_relative_day_of_month(start, n)
      the_next = get_xth_day_of_month(every_xth_day, day_of_week, start.month, start.year)
      if the_next.nil? || the_next <= start
        # the nth day is already passed in this month, go to next month and try
        # again
        the_next += n.months

        # TODO: if there is still no match, start will be set to nil. if we ever
        # support 5th day of the month, we need to handle this case
        the_next = get_xth_day_of_month(every_xth_day, day_of_week, the_next.month, the_next.year)
      end
      the_next
    end

    def recurrence_pattern_for_specific_day
      on_day = " #{I18n.t('todos.recurrence.pattern.on_day_n', :n => every_x_day)}"
      if every_x_month > 1
        I18n.t("todos.recurrence.pattern.every_n_months", :n => every_x_month) + on_day
      else
        I18n.t("todos.recurrence.pattern.every_month") + on_day
      end
    end

    def recurrence_pattern_for_relative_day_in_month
      n_months = if every_x_month2 > 1
                   "#{every_x_month2} #{I18n.t('common.months')}"
                 else
                   I18n.t('common.month')
                 end
      I18n.t('todos.recurrence.pattern.every_xth_day_of_every_n_months',
        x:        xth(every_xth_day),
        day:      day_of_week_as_text(day_of_week),
        n_months: n_months)
    end
  end
end
