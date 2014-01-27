module RecurringTodos

  class DailyRepeatPattern < AbstractRepeatPattern

    def initialize(user, attributes)
      super user, attributes
      @selector = get_selector('daily_selector')
    end

    def mapped_attributes
      mapping = @attributes

      mapping[:only_work_days] = only_work_days?(@selector)

      mapping[:every_other1] = mapping['daily_every_x_days']
      mapping = mapping.except('daily_every_x_days')

      mapping
    end

    def every_x_days
      @recurring_todo.every_other1
    end

    private

    def only_work_days?(daily_selector)
      case daily_selector
      when 'daily_every_x_day'
        return false
      when 'daily_every_work_day'
        return true
      end
    end

    def valid_selector?(selector)
      %w{daily_every_x_day daily_every_work_day}.include?(selector)
    end

  end
  
end