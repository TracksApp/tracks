module RecurringTodos

  class MonthlyRepeatPattern < AbstractRepeatPattern

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
        on_day = " #{I18n.t('todos.recurrence.pattern.on_day_n', :n => every_x_day)}"
        if every_xth_day(0) > 1
          I18n.t("todos.recurrence.pattern.every_n", :n => every_xth_day) + " " + I18n.t('common.months') + on_day
        else
          I18n.t("todos.recurrence.pattern.every_month") + on_day
        end
      else
        n_months = if get(:every_other2) > 1
                     "#{get(:every_other2)} #{I18n.t('common.months')}"
                   else
                     I18n.t('common.month')
                   end
        I18n.t('todos.recurrence.pattern.every_xth_day_of_every_n_months',
          :x => xth(every_xth_day), :day => day_of_week_as_text(day_of_week), :n_months => n_months)
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

  end
  
end