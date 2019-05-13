class AddUserAuthType < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :auth_type, :string, :default => 'database', :null => false
  end

  def self.down
    remove_column :users, :auth_type
  end
end
