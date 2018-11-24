class DoneTodos


  def self.done_todos_for_container(todos)
    completed_todos = todos.completed
    return done_today(completed_todos), done_rest_of_week(completed_todos), done_rest_of_month(completed_todos)
  end

  def self.done_today(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    # TODO: refactor to remove outer hash from includes param
    todos.completed_after(beginning_of_day).includes(includes[:include])
  end

  def self.done_rest_of_week(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, beginning_of_day, beginning_of_week)
  end

  def self.done_rest_of_month(todos, includes = {:include => Todo::DEFAULT_INCLUDES})
    done_between(todos, includes, beginning_of_week, beginning_of_month)
  end

  def self.completed_period(date)
    return nil if date.nil? 

    return "today"         if date >= end_of_day  # treat todos with completed_at in future as done today (happens in tests)
    return "today"         if date.between?(beginning_of_day, end_of_day)
    return "rest_of_week"  if date >= beginning_of_week
    return "rest_of_month" if date >= beginning_of_month
    return nil
  end

  def self.remaining_in_container(todos, period)
    count = self.send("done_#{period}", todos.completed, {}).count
    return nil if period.nil?
    return count
  end

  private

  def self.done_between(todos, includes, start_date, end_date)
    # TODO: refactor to remove outer hash from includes param
    todos.completed_before(start_date).completed_after(end_date).includes(includes[:include])
  end

  def self.beginning_of_day
    Time.zone.now.beginning_of_day
  end

  def self.end_of_day
    Time.zone.now.end_of_day
  end

  def self.beginning_of_week
    Time.zone.now.beginning_of_week
  end

  def self.beginning_of_month
    Time.zone.now.beginning_of_month
  end

end
