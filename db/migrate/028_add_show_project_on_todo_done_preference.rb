class AddShowProjectOnTodoDonePreference < ActiveRecord::Migration
  def self.up
      add_column :preferences, :show_project_on_todo_done, :boolean, :default => false, :null => false
    end

    def self.down
      remove_column :preferences, :show_project_on_todo_done
    end
end
