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
    todos.completed_before(Time.zone.now.beginning_of_day).completed_after(Time.zone.now.beginning_of_week).all(includes)
  end

  def self.done_this_month(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    todos.completed_before(Time.zone.now.beginning_of_week).completed_after(Time.zone.now.beginning_of_month).all(includes)
  end
end
