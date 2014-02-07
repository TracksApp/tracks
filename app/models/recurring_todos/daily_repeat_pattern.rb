module RecurringTodos

  class DailyRepeatPattern < AbstractRepeatPattern

    def initialize(user)
      super user
    end

    def every_x_days
      @recurring_todo.every_other1
    end

  end
  
end