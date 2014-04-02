module RecurringTodos

  class DailyRecurringTodosBuilder < AbstractRecurringTodosBuilder
    attr_reader :recurring_todo, :pattern

    def initialize(user, attributes)
      super(user, attributes, DailyRepeatPattern)
    end

    def attributes_to_filter
      %w{daily_selector daily_every_x_days}
    end

    def map_attributes(mapping)
      mapping.set(:only_work_days, only_work_days?(@selector))
      mapping.set(:every_other1,   mapping.get(:daily_every_x_days))
      mapping.except(:daily_every_x_days)
    end

    def only_work_days?(daily_selector)
      { 'daily_every_x_day' => false, 
        'daily_every_work_day' => true}[daily_selector]
    end

    def selector_key
      :daily_selector
    end

    def valid_selector?(selector)
      %w{daily_every_x_day daily_every_work_day}.include?(selector)
    end

  end

end