class DoneTodos
  def self.done_todos_for_container(user)
    completed_todos = user.todos.completed
    return done_today(completed_todos), done_rest_of_week(completed_todos), done_rest_of_month(completed_todos)
  end

  def self.done_today(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    start_of_this_day = Time.zone.now.beginning_of_day
    todos.completed_after(start_of_this_day).all(includes)
  end

  def self.done_rest_of_week(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_week)
  end

  def self.done_rest_of_month(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_month)
  end

  def self.completed_period(date)
    return nil if date.nil?

    period = nil
    period = "rest_of_month" if date > Time.zone.now.beginning_of_month
    period = "rest_of_week"  if date > Time.zone.now.beginning_of_week
    period = "today"         if date > Time.zone.now.beginning_of_day

    return period
  end

  def self.remaining_in_container(user, period)
    count = self.send("done_#{period}", user.todos.completed, {}).count
    return nil if period.nil?
    return count
  end

  private

  def self.done_between(todos, includes, start_date, end_date)
    todos.completed_before(start_date).completed_after(end_date).all(includes)
  end
end
