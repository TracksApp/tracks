class AddShowAlwaysToRecurringTodo < ActiveRecord::Migration
  def self.up
    add_column :recurring_todos, :show_always, :boolean
    recurring_todos = RecurringTodo.all
    recurring_todos.each do |recurring_todo|
      if recurring_todo.show_from_delta == 0 or recurring_todo.show_from_delta.nil?
        recurring_todo.show_always = true
        recurring_todo.save!
      end
    end
  end

  def self.down
    remove_column :recurring_todos, :show_always
  end
end
