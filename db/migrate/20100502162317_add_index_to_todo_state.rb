class AddIndexToTodoState < ActiveRecord::Migration
  def self.up
    add_index :todos, :state
  end

  def self.down
    remove_index :todos, :state
  end
end