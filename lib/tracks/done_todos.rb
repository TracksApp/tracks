class DoneTodos
  def self.done_todos_for_container(container)
    completed_todos = container.todos.completed
    return done_today(completed_todos), done_this_week(completed_todos), done_this_month(completed_todos)
  end

  def self.done_today(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_day = Time.zone.now.beginning_of_day
    todos.completed_after(start_of_this_day).all(includes)
  end

  def self.done_this_week(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_week)
  end

  def self.done_this_month(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_month)
  end

  private

  def self.done_between(todos, includes, start_date, end_date)
    todos.completed_before(start_date).completed_after(end_date).all(includes)
  end
end
