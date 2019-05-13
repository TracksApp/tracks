class AddIndexToTodoState < ActiveRecord::Migration[5.2]
  def self.up
    add_index :todos, :state
  end

  def self.down
    remove_index :todos, :state
  end
end
