class CreatedAt < ActiveRecord::Migration
  def self.up
    rename_column :todos, :created, :created_at
  end

  def self.down
    rename_column :todos, :created_at, :created
  end
end
