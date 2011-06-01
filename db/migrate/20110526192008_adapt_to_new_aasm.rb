class AdaptToNewAasm < ActiveRecord::Migration
  def self.up
    change_column :todos,           :state, :string, :limit => 20, :default => "", :null => false
    change_column :projects,        :state, :string, :limit => 20, :default => "", :null => false
    change_column :recurring_todos, :state, :string, :limit => 20, :default => "", :null => false
  end

  def self.down
    change_column :todos,           :state, :string, :limit => 20, :default => "immediate", :null => false
    change_column :projects,        :state, :string, :limit => 20, :default => "active", :null => false
    change_column :recurring_todos, :state, :string, :limit => 20, :default => "active", :null => false
  end
end
