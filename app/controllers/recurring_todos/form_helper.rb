module RecurringTodos

  class FormHelper

    def initialize(recurring_todo)
      @recurring_todo = recurring_todo
    end

    def create_pattern(pattern_class)
      pattern = pattern_class.new(@recurring_todo.user)
      pattern.build_from_recurring_todo(@recurring_todo)
      pattern
    end

    def daily_pattern
      @daily_pattern ||= create_pattern(DailyRepeatPattern)
    end

    def weekly_pattern
      @weekly_pattern ||= create_pattern(WeeklyRepeatPattern)
    end

    def monthly_pattern
      @monthly_pattern ||= create_pattern(MonthlyRepeatPattern)
    end

    def yearly_pattern
      @yearly_pattern ||= create_pattern(YearlyRepeatPattern)
    end

    def method_missing(method, *args)
      if method.to_s =~ /^daily_(.+)$/
        daily_pattern.send($1, *args)
      elsif method.to_s =~ /^weekly_(.+)$/
        weekly_pattern.send($1, *args)
      elsif method.to_s =~ /^monthly_(.+)$/
        monthly_pattern.send($1, *args)
      elsif method.to_s =~ /^yearly_(.+)$/
        yearly_pattern.send($1, *args)
      elsif method.to_s =~ /^on_(.+)$/ # on_monday, on_tuesday, etc.
        weekly_pattern.send(method, *args)
      else
        # no match, let @recurring_todo handle it, or fail
        @recurring_todo.send(method, *args)
      end
    end

  end

end