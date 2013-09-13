class AddSubclassAttrToTodos < ActiveRecord::Migration

  class Todo < ActiveRecord::Base; end
  class Immediate < Todo; end
  
  def self.up
    add_column :todos, :type, :string, :null => false, :default => "Immediate"
    add_column :todos, :show_from, :date
    Todo.all.each { |todo| todo.type = "Immediate" }
  end

  def self.down
    remove_column :todos, :type
    remove_column :todos, :show_from
  end
end
