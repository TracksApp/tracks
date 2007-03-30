class IndexOnUserLogin < ActiveRecord::Migration
  def self.up
    add_index :users, :login
  end

  def self.down
    remove_index :users, :login
  end
end
