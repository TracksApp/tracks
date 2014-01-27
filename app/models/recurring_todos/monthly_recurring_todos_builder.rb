module RecurringTodos

  class MonthlyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = MonthlyRepeatPattern.new(user, @filterred_attributes)
    end

    def filter_attributes(attributes)
      @filterred_attributes = filter_generic_attributes(attributes)

      %w{
        monthly_selector       monthly_every_x_day   monthly_every_x_month 
        monthly_every_x_month2 monthly_every_xth_day monthly_day_of_week    
      }.each do |key| 
        @filterred_attributes[key] = attributes[key] if attributes.key?(key)
      end
      
      @filterred_attributes
    end

  end

end