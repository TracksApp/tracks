class NoDefaultAdminEmail < ActiveRecord::Migration
  def up
    remove_column :preferences, :admin_email
  end

  def down
    add_column :preferences, :admin_email, :string, {:default => "butshesagirl@rousette.org.uk", :null => false}
  end
end
