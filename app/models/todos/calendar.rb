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
      user.todos.not_completed.
        where('todos.due <= ?', today).
        includes(included_tables).
        reorder("due")
    end

    def due_this_week
      user.todos.not_completed.
        where('todos.due > ? AND todos.due <= ?', today, Time.zone.now.end_of_week).
        includes(included_tables).
        reorder("due")
    end

    def due_next_week
      user.todos.not_completed.
        where('todos.due > ? AND todos.due <= ?', end_of_the_week, end_of_next_week).
        includes(included_tables).
        reorder("due")
    end

    def due_this_month
      user.todos.not_completed.
        where('todos.due > ? AND todos.due <= ?', end_of_next_week, end_of_the_month).
        includes(included_tables).
        reorder("due")
    end

    def due_after_this_month
      user.todos.not_completed.
        where('todos.due > ?', end_of_the_month).
        includes(included_tables).
        reorder("due")
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

  end
end
