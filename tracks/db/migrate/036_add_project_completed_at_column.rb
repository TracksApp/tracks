class AddProjectCompletedAtColumn < ActiveRecord::Migration
  def self.up
    add_column :projects, :completed_at, :datetime
  end

  def self.down
    remove_column :projects, :completed_at
  end
end
