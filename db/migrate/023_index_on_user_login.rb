class IndexOnUserLogin < ActiveRecord::Migration[5.2]
  def self.up
    add_index :users, :login
  end

  def self.down
    remove_index :users, :login
  end
end
