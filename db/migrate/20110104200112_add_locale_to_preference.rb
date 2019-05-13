class AddLocaleToPreference < ActiveRecord::Migration[5.2]
  def self.up
    add_column :preferences, :locale, :string
  end

  def self.down
    remove_column :preferences, :locale
  end
end
