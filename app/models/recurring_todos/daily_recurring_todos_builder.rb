module RecurringTodos

  class DailyRecurringTodosBuilder < AbstractRecurringTodosBuilder
    attr_reader :recurring_todo, :pattern

    def initialize(user, attributes)
      super(user, attributes)
      @pattern = DailyRepeatPattern.new(user, @filterred_attributes)
    end

    def filter_attributes(attributes)
      @filterred_attributes = filter_generic_attributes(attributes)
      %w{daily_selector daily_every_x_days}.each{|key| @filterred_attributes[key] = attributes[key] if attributes.key?(key)}
      @filterred_attributes
    end

  end

end