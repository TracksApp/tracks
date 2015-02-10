module RecurringTodos

  class WeeklyRecurrencePattern < AbstractRecurrencePattern

    def initialize(user)
      super user
    end

    def every_x_week
      get :every_other1
    end

    { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 0 }.each do |day, number|
      define_method("on_#{day}") do
        on_xday number
      end
    end

    def on_xday(n)
      get(:every_day) && get(:every_day)[n, 1] != ' '
    end

    def recurrence_pattern
      if every_x_week > 1
        I18n.t("todos.recurrence.pattern.every_n", :n => every_x_week) + " " + I18n.t("common.weeks")
      else
        I18n.t('todos.recurrence.pattern.weekly')
      end
    end

    def validate
      super
      validate_not_blank(every_x_week, "Every other nth week may not be empty for weekly recurrence setting")
      something_set = %w{sunday monday tuesday wednesday thursday friday saturday}.inject(false) { |set, day| set || self.send("on_#{day}") }
      errors[:base] << "You must specify at least one day on which the todo recurs" unless something_set
    end

    def get_next_date(previous)
      start = determine_start_date(previous)

      day = find_first_day_in_this_week(start)
      return day unless day == -1

      # we did not find anything this week, so check the nth next, starting from
      # sunday
      start = start + self.every_x_week.week - (start.wday()).days

      start = find_first_day_in_this_week(start)
      return start unless start == -1

      raise Exception.new, "unable to find next weekly date (#{self.every_day})"
    end

    private

    def determine_start_date(previous)
      if previous.nil?
        return self.start_from || Time.zone.now
      else
        start = previous + 1.day
        if start.wday() == 0
          # we went to a new week, go to the nth next week and find first match
          # that week. Note that we already went into the next week, so -1
          start += (every_x_week-1).week
        end
        unless self.start_from.nil?
          # check if the start_from date is later than previous. If so, use
          # start_from as start to search for next date
          start = self.start_from if self.start_from > previous
        end
        return start
      end
    end

    def find_first_day_in_this_week(start)
      # check if there are any days left this week for the next todo
      start.wday().upto 6 do |i|
        return start + (i-start.wday()).days if on_xday(i)
      end
      -1
    end


  end

end
