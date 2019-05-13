class NoDefaultAdminEmail < ActiveRecord::Migration[5.2]
  def up
    remove_column :preferences, :admin_email
  end

  def down
    add_column :preferences, :admin_email, :string, {:default => "butshesagirl@rousette.org.uk", :null => false}
  end
end
