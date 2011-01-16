class AddLocaleToPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :locale, :string
  end

  def self.down
    remove_column :preferences, :locale
  end
end
