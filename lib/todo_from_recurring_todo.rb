class TodoFromRecurringTodo
  attr_reader :user, :recurring_todo, :todo

  def initialize(user, recurring_todo)
    @user = user
    @recurring_todo = recurring_todo
  end

  def create(time = nil)
    @todo = build_todo(time)
    save_todo
    update_recurring_todo
    return todo.persisted? ? todo : nil
  end

  def build_todo(time)
    user.todos.build(attributes).tap do |todo|
      todo.recurring_todo_id = recurring_todo.id
      todo.due = recurring_todo.get_due_date(time)
      todo.show_from = show_from_date(time)
    end
  end

  def update_recurring_todo
    recurring_todo.increment_occurrences
    recurring_todo.toggle_completion! if recurring_todo.done?(end_date)
  end

  def end_date
    todo.due ? todo.due : todo.show_from
  end

  def attributes
    {
      :description => recurring_todo.description,
      :notes       => recurring_todo.notes,
      :project_id  => recurring_todo.project_id,
      :context_id  => recurring_todo.context_id
    }
  end

  def save_todo
    if todo.save
      todo.tag_with(recurring_todo.tag_list)
      todo.tags.reload
    end
  end

  def show_from_date(time)
    show_from_date = recurring_todo.get_show_from_date(time)
    if show_from_date && show_from_date >= Time.zone.now
      show_from_date
    end
  end
end
