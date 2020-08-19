class AddThemeToPreference < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :theme, :string
  end
end
