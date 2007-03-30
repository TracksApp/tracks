class AddUserOpenIdUrl < ActiveRecord::Migration
  def self.up
    add_column :users, :open_id_url, :string
  end

  def self.down
    remove_column :users, :open_id_url
  end
end
