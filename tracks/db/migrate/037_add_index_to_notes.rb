class AddIndexToNotes < ActiveRecord::Migration
  def self.up
    add_index :notes, [:project_id]
    add_index :notes, [:user_id]
  end

  def self.down
    remove_index :notes, [:user_id]
    remove_index :notes, [:project_id] 
  end
end
