class AddTitleDateFormatPreference < ActiveRecord::Migration
    def self.up
      add_column :preferences, :title_date_format, :string, :limit => 255, :default => '%A, %d %B %Y', :null => false
    end

    def self.down
      remove_column :preferences, :title_date_format
    end
end
