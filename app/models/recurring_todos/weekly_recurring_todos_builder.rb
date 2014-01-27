module RecurringTodos

  class WeeklyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = WeeklyRepeatPattern.new(user, @filterred_attributes)
    end

    def filter_attributes(attributes)
      @filterred_attributes = filter_generic_attributes(attributes)

      weekly_attributes = %w{weekly_selector weekly_every_x_week}
      %w{monday tuesday wednesday thursday friday saturday sunday}.each{|day| weekly_attributes << "weekly_return_#{day}"}
      weekly_attributes.each{|key| @filterred_attributes[key] = attributes[key]  if attributes.key?(key)}

      @filterred_attributes
    end

  end

end