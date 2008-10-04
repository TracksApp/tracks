class ChangeDatesToDatetimes < ActiveRecord::Migration
  def self.up
    change_column :todos, :show_from, :datetime
    change_column :todos, :due, :datetime
    change_column :recurring_todos, :start_from, :datetime
    change_column :recurring_todos, :end_date, :datetime

    User.all(:include => [:todos, :recurring_todos]).each do |user|
      if user.prefs
        user.todos.each do |todo|
          todo.update_attribute(:show_from, user.at_midnight(todo.show_from)) unless todo.show_from.nil?
          todo.update_attribute(:due, user.at_midnight(todo.due)) unless todo.due.nil?
        end

        user.recurring_todos.each do |todo|
          todo.update_attribute(:start_from, user.at_midnight(todo.start_from)) unless todo.start_from.nil?
          todo.update_attribute(:end_date, user.at_midnight(todo.end_date)) unless todo.end_date.nil?
        end
      else # weird...no preferences for this user
        user.todos.each do |todo|
          todo.update_attribute(:show_from, at_midnight(todo.show_from)) unless todo.show_from.nil?
          todo.update_attribute(:due, at_midnight(todo.due)) unless todo.due.nil?
        end

        user.recurring_todos.each do |todo|
          todo.update_attribute(:start_from, at_midnight(todo.start_from)) unless todo.start_from.nil?
          todo.update_attribute(:end_date, at_midnight(todo.end_date)) unless todo.end_date.nil?
        end
    end
  end

  def at_midnight(date)
    return Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
  end

  def self.down
    change_column :todos, :show_from, :date
    change_column :todos, :due, :date
    change_column :recurring_todos, :start_from, :date
    change_column :recurring_todos, :end_date, :date
  end
end
