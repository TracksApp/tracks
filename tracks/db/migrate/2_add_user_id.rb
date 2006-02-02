class AddUserId < ActiveRecord::Migration
  def self.up
    add_column "contexts",   "user_id", :integer, :default => 1
    add_column "projects",   "user_id", :integer, :default => 1 
    add_column "todos",      "user_id", :integer, :default => 1 
    execute "UPDATE 'contexts' SET 'user_id' = 1;"
    execute "UPDATE 'projects' SET 'user_id' = 1;"
    execute "UPDATE 'todos' SET 'user_id' = 1;"
  end

  def self.down
    remove_column :contexts,   :user_id
    remove_column :projects,   :user_id
    remove_column :todos,      :user_id
  end
end
