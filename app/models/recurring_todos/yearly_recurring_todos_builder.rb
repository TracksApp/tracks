module RecurringTodos

  class YearlyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = YearlyRepeatPattern.new(user, @filterred_attributes)
    end

    def filter_attributes(attributes)
      @filterred_attributes = filter_generic_attributes(attributes)

      %w{ yearly_selector    yearly_month_of_year yearly_month_of_year2 
          yearly_every_x_day yearly_every_xth_day yearly_day_of_week    
      }.each do |key| 
        @filterred_attributes[key] = attributes[key] if attributes.key?(key)
      end
      
      @filterred_attributes
    end

  end

end