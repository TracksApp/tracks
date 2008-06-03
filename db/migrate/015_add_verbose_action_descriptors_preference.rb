class AddVerboseActionDescriptorsPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :verbose_action_descriptors, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :verbose_action_descriptors
  end
end
