class AddProjectTimestamps < ActiveRecord::Migration[5.2]
  def self.up
    add_column :projects, :created_at, :timestamp
    add_column :projects, :updated_at, :timestamp
  end
    

  def self.down
    remove_column :projects, :created_at
    remove_column :projects, :updated_at
  end
end
