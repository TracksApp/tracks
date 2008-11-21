class AddUpdatedAtToTodos < ActiveRecord::Migration
  def self.up
      add_column :todos, :updated_at, :timestamp
        end
          def self.down
              remove_column :todos, :updated_at
                end
                end