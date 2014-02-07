module RecurringTodos

  class AbstractRepeatPattern

    attr_accessor :attributes

    def initialize(user)
      @user = user
    end

    def build_recurring_todo(attributes)
      @recurring_todo = @user.recurring_todos.build(attributes)
    end

    def update_recurring_todo(recurring_todo, attributes)
      recurring_todo.assign_attributes(attributes)
      recurring_todo
    end
    
  end
  
end