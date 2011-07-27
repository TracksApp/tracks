class ChangeCryptedPasswordLength < ActiveRecord::Migration
  def self.up
    change_column 'users', 'crypted_password', :string, :limit => 60
  end

  def self.down
    change_column 'users', 'crypted_password', :string, :limit => 40
  end
end
