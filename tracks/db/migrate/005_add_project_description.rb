class AddProjectDescription < ActiveRecord::Migration
  def self.up
    add_column :projects, :description, :text
  end

  def self.down
    remove_column :projects, :description
  end
end
