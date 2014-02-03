module RecurringTodos

  class DailyRecurringTodosBuilder < AbstractRecurringTodosBuilder
    attr_reader :recurring_todo, :pattern

    def initialize(user, attributes)
      super(user, attributes)

      @pattern = DailyRepeatPattern.new(user, @filterred_attributes)
    end

    def attributes_to_filter
      %w{daily_selector daily_every_x_days}
    end

  end

end