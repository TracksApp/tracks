class AdaptToNewAasm < ActiveRecord::Migration
  def self.up
    change_column_default :todos, :state, nil
    change_column_default :projects, :state, nil
    change_column_default :recurring_todos, :state, nil
  end

  def self.down
    change_column :todos,           :state, :string, :limit => 20, :default => "immediate", :null => false
    change_column :projects,        :state, :string, :limit => 20, :default => "active", :null => false
    change_column :recurring_todos, :state, :string, :limit => 20, :default => "active", :null => false
  end
end
