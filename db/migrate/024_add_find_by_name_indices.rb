class AddFindByNameIndices < ActiveRecord::Migration
  def self.up
    add_index :projects, [:user_id, :name]
    add_index :contexts, [:user_id, :name]
  end

  def self.down
    remove_index :projects, [:user_id, :name]
    remove_index :contexts, [:user_id, :name]
  end
end
