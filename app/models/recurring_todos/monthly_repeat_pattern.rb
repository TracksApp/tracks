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

    def every_xth_day
      get :every_other2
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

    def validate
      super

      case recurrence_selector
      when 0 # 'monthly_every_x_day'
        validate_not_blank(every_x_month, "Every other nth month may not be empty for recurrence setting")
      when 1 # 'every_xth_day'
        validate_not_blank(every_x_month2, "Every other nth month may not be empty for recurrence setting")
        validate_not_blank(day_of_week, "The day of the month may not be empty for recurrence setting")
      else
        raise Exception.new, "unexpected value of recurrence selector '#{recurrence_selector}'"
      end
    end

  end
  
end