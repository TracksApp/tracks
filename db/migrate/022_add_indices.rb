class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :todos, [:user_id, :state]
    add_index :todos, [:user_id, :project_id]
    add_index :todos, [:project_id]
    add_index :todos, [:context_id]
    add_index :todos, [:user_id, :context_id]
    add_index :preferences, :user_id
    add_index :projects, :user_id
    add_index :contexts, :user_id
  end

  def self.down
    remove_index :contexts, :user_id
    remove_index :projects, :user_id
    remove_index :preferences, :user_id
    remove_index :todos, [:user_id, :context_id]
    remove_index :todos, [:project_id]
    remove_index :todos, [:context_id]
    remove_index :todos, [:user_id, :project_id]
    remove_index :todos, [:user_id, :state]
  end
end
