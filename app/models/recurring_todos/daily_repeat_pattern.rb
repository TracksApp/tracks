module RecurringTodos

  class DailyRepeatPattern < AbstractRepeatPattern

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
        I18n.t("todos.recurrence.pattern.every_n", :n => every_x_days) + " " + I18n.t("common.days_midsentence.other")
      else
        I18n.t("todos.recurrence.pattern.every_day")
      end
    end

    def validate
      super
      errors[:base] << "Every other nth day may not be empty for this daily recurrence setting" if (!only_work_days?) && every_x_days.blank?
    end


  end
  
end