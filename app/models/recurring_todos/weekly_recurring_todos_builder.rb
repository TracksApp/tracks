module RecurringTodos

  class WeeklyRecurringTodosBuilder < AbstractRecurringTodosBuilder

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = WeeklyRepeatPattern.new(user, @filterred_attributes)
    end

    def attributes_to_filter
      %w{weekly_selector weekly_every_x_week} + %w{monday tuesday wednesday thursday friday saturday sunday}.map{|day| "weekly_return_#{day}" }
    end


  end

end