class ChangeDatesToDatetimes < ActiveRecord::Migration
  def self.up
    change_column :todos, :show_from, :datetime
    change_column :todos, :due, :datetime
    change_column :recurring_todos, :start_from, :datetime
    change_column :recurring_todos, :end_date, :datetime
    
    User.all(:include => [:todos, :recurring_todos]).each do |user|
      zone = TimeZone[user.prefs.time_zone]
      user.todos.each do |todo|
        todo.update_attribute(:show_from, user.at_midnight(todo.show_from)) unless d.nil?
        todo.update_attribute(:due, user.at_midnight(todo.due)) unless d.nil?
      end
      
      user.recurring_todos.each do |todo|
        todo.update_attribute(:start_from, user.at_midnight(todo.start_from)) unless d.nil?
        todo.update_attribute(:end_date, user.at_midnight(todo.end_date)) unless d.nil?
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
