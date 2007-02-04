class AddContextTimestamps < ActiveRecord::Migration

  def self.up
    add_column :contexts, :created_at, :timestamp
    add_column :contexts, :updated_at, :timestamp
  end

  def self.down
    remove_column :contexts, :created_at
    remove_column :contexts, :updated_at
  end

end
