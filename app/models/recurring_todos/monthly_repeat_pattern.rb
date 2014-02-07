module RecurringTodos

  class MonthlyRepeatPattern < AbstractRepeatPattern

    def initialize(user)
      super user
    end

    def every_x_day?
      @recurring_todo.recurrence_selector == 0
    end

    def every_xth_day?
      @recurring_todo.recurrence_selector == 1
    end

  end
  
end