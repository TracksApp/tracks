class ChangeDatesToDatetimes < ActiveRecord::Migration
  def self.up
    change_column :todos, :show_from, :datetime
    change_column :todos, :due, :datetime
    change_column :recurring_todos, :start_from, :datetime
    change_column :recurring_todos, :end_date, :datetime

    User.includes(:todos, :recurring_todos).each do |user|
      if !user.prefs ## ugly hack for strange edge-case of not having preferences object
        user.instance_eval do
          def at_midnight(date)
            return Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
          end
          def time
            Time.zone.now
          end
        end
      end
      user.todos.each do |todo|
        todo[:show_from] = user.at_midnight(todo.show_from) unless todo.show_from.nil?
        todo[:due] = user.at_midnight(todo.due) unless todo.due.nil?
        todo.save_with_validation(false)
      end

      user.recurring_todos.each do |todo|
        todo[:start_from] = user.at_midnight(todo.start_from) unless todo.start_from.nil?
        todo[:end_date] = user.at_midnight(todo.end_date) unless todo.end_date.nil?
        todo.save_with_validation(false)
      end
    end
  end

  def self.down
    change_column :todos, :show_from, :date
    change_column :todos, :due, :date
    change_column :recurring_todos, :start_from, :date
    change_column :recurring_todos, :end_date, :date
  end
end
