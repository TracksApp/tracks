module Todos
  class Calendar

    attr_reader :user, :included_tables

    def initialize(user)
      @user = user
      @included_tables = Todo::DEFAULT_INCLUDES
    end

    def projects
      user.projects
    end

    def due_today
      actions.due_today
    end

    def due_this_week
      actions.due_between(today, end_of_the_week)
    end

    def due_next_week
      actions.due_between(end_of_the_week, end_of_next_week)
    end

    def due_this_month
      actions.due_between(end_of_next_week, end_of_the_month)
    end

    def due_after_this_month
      actions.due_after(end_of_the_month)
    end

    def today
      @today ||= Time.zone.now
    end

    def end_of_the_week
      @end_of_the_week ||= today.end_of_week
    end

    def end_of_next_week
      @end_of_next_week ||= end_of_the_week + 7.days
    end

    def end_of_the_month
      @end_of_the_month ||= today.end_of_month
    end

  private

    def actions
      user.todos.not_completed.includes(included_tables).reorder("due")
    end

  end
end
