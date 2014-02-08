module RecurringTodos

  class YearlyRepeatPattern < AbstractRepeatPattern

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

  end
  
end