module RecurringTodos

  class MonthlyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = MonthlyRepeatPattern.new(user, @filterred_attributes)
    end

    def attributes_to_filter
      %w{
        monthly_selector       monthly_every_x_day   monthly_every_x_month 
        monthly_every_x_month2 monthly_every_xth_day monthly_day_of_week    
      }
    end

  end

end