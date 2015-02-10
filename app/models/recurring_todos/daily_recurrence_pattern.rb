module RecurringTodos

  class DailyRecurrencePattern < AbstractRecurrencePattern

    def initialize(user)
      super user
    end

    def every_x_days
      get :every_other1
    end

    def only_work_days?
      get :only_work_days
    end

    def recurrence_pattern
      if only_work_days?
        I18n.t("todos.recurrence.pattern.on_work_days")
      elsif every_x_days > 1
        I18n.t("todos.recurrence.pattern.every_n_days", :n => every_x_days)
      else
        I18n.t("todos.recurrence.pattern.every_day")
      end
    end

    def validate
      super
      errors[:base] << "Every other nth day may not be empty for this daily recurrence setting" if (!only_work_days?) && every_x_days.blank?
    end

    def get_next_date(previous)
      # previous is the due date of the previous todo or it is the completed_at
      # date when the completed_at date is after due_date (i.e. you did not make
      # the due date in time)

      start = determine_start(previous, 1.day)

      if only_work_days?
        # jump over weekend if necessary
        return start + 2.day if start.wday() == 6 # saturday
        return start + 1.day if start.wday() == 0 # sunday
        return start
      else
        # if there was no previous todo, do not add n: the first todo starts on
        # today or on start_from
        return previous == nil ? start : start+every_x_days.day-1.day
      end
    end

  end
end
