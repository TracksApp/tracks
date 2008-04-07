class AddRememberMeToUser < ActiveRecord::Migration
  def self.up
    rename_column :users, 'password', 'crypted_password' #bug in sqlite requires column names as strings
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires_at, :datetime
  end

  def self.down
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    rename_column :users,  'crypted_password', 'password' #bug in sqlite requires column names as strings
  end
end
