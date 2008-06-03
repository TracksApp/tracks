class AddUserAuthType < ActiveRecord::Migration
  def self.up
    add_column :users, :auth_type, :string, :default => 'database', :null => false
  end

  def self.down
    remove_column :users, :auth_type
  end
end
