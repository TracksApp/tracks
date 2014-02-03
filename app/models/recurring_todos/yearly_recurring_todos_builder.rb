module RecurringTodos

  class YearlyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = YearlyRepeatPattern.new(user, @filterred_attributes)
    end

    def attributes_to_filter
      %w{ yearly_selector     yearly_month_of_year  yearly_month_of_year2 
          yearly_every_x_day  yearly_every_xth_day  yearly_day_of_week    
      }
    end

  end

end