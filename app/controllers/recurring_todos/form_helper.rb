module RecurringTodos

  class FormHelper

    def initialize(recurring_todo)
      @recurring_todo = recurring_todo

      @method_map = {
        # delegate daily_xxx to daily_pattern.xxx
        "daily"   => {prefix: "",    method: daily_pattern},
        "weekly"  => {prefix: "",    method: weekly_pattern},
        "monthly" => {prefix: "",    method: monthly_pattern},
        "yearly"  => {prefix: "",    method: yearly_pattern},
        # delegate on_xxx to weekly_pattern.on_xxx
        "on"      => {prefix: "on_", method: weekly_pattern}
      }
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
      # delegate daily_xxx to daily_pattern, weekly_xxx to weekly_pattern, etc.
      if method.to_s =~ /^([^_]+)_(.+)$/
        return @method_map[$1][:method].send(@method_map[$1][:prefix]+$2, *args) unless @method_map[$1].nil?
      end

      # no match, let @recurring_todo handle it, or fail
      @recurring_todo.send(method, *args)
    end

  end

end