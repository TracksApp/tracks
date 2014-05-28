class AddScheduleToRecurringTodos < ActiveRecord::Migration
  def up
    add_column :recurring_todos, :schedule, :text

    RecurringTodo.reset_column_information

    say "Updating recurring todos. This may take a while."
    # Call save! on each todo to force generation of schedule
    i=0; max = RecurringTodo.all.count; start = Time.now
    RecurringTodo.all.each do |todo|
      todo.save(:validate => false)
      i = i + 1
      if i%250==0
        elapsed_sec = (Time.now-start)
        remaining = (elapsed_sec / i)*(max-i)
        say "Progress: #{i} / #{max} (#{(i.to_f/max.to_f*100.0).floor}%) ETA=#{remaining.floor}s"
      end
    end
    say "Done: #{i} / #{max}"
  end

  def down
    remove_column :recurring_todos, :schedule
  end

end
