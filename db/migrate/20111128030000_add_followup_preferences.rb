class AddFollowupPreferences < ActiveRecord::Migration

  def self.up
    add_column :preferences, :followup_context_id, :integer, :default => 1, :null => false
    add_column :preferences, :followup_defer, :integer, :default => 7, :null => false
  end

  def self.down
    remove_column :preferences, :followup_context_id
    remove_column :preferences, :followup_defer
  end
end
