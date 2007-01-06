class AddTimeZonePreference < ActiveRecord::Migration

  def self.up
      add_column :preferences, :time_zone, :string, :limit => 255, :default => 'London', :null => false
    end

    def self.down
      remove_column :preferences, :time_zone
    end
    
end
