class AddIndicesToDependencyTable < ActiveRecord::Migration
  def self.up
    add_index :dependencies, :successor_id
    add_index :dependencies, :predecessor_id
    add_index :projects, :state
    add_index :projects, [:user_id, :state]
  end

  def self.down
    remove_index :dependencies, :successor_id
    remove_index :dependencies, :predecessor_id
    remove_index :projects, :state
    remove_index :projects, [:user_id, :state]
  end
end
