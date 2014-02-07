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
      mapping[:only_work_days] = only_work_days?(@selector)

      mapping[:every_other1] = mapping['daily_every_x_days']
      mapping = mapping.except('daily_every_x_days')

      mapping
    end

    def only_work_days?(daily_selector)
      case daily_selector
      when 'daily_every_x_day'
        return false
      when 'daily_every_work_day'
        return true
      end
    end

    def selector_key
      'daily_selector'
    end

    def valid_selector?(selector)
      %w{daily_every_x_day daily_every_work_day}.include?(selector)
    end

  end

end