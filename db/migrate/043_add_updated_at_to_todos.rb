class AddUpdatedAtToTodos < ActiveRecord::Migration
  def self.up
      add_column :todos, :updated_at, :timestamp
      execute 'update todos set updated_at = created_at where completed_at IS NULL'
      execute 'update todos set updated_at = completed_at where NOT (completed_at IS NULL)'
  end
  def self.down
      remove_column :todos, :updated_at
  end
end
