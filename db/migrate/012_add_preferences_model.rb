class AddPreferencesModel < ActiveRecord::Migration

  class User < ActiveRecord::Base; serialize :preferences; end

  def self.up
      create_table :preferences do |t|
        t.column :user_id,     :integer, :null => false
        t.column :date_format, :string,  :limit => 40, :null => false, :default => '%d/%m/%Y'
        t.column :week_starts, :integer, :null => false, :default => 0
        t.column :show_number_completed, :integer, :null => false, :default => 5
        t.column :staleness_starts, :integer, :null => false, :default => 7
        t.column :show_completed_projects_in_sidebar, :boolean, :default => true, :null => false
        t.column :show_hidden_contexts_in_sidebar, :boolean, :default => true, :null => false
        t.column :due_style, :integer, :null => false, :default => 0
        t.column :admin_email, :string, :limit => 255, :null => false, :default => 'butshesagirl@rousette.org.uk'
        t.column :refresh, :integer, :null => false, :default => 0
      end
    end

  def self.down
    drop_table :preferences
  end
end
