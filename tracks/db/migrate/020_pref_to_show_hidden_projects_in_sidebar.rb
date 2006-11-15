class PrefToShowHiddenProjectsInSidebar < ActiveRecord::Migration

  class Preferences < ActiveRecord::Base; end

  def self.up
    add_column :preferences, :show_hidden_projects_in_sidebar, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :preferences, :show_hidden_projects_in_sidebar
  end

end
