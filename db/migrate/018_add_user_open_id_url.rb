class AddUserOpenIdUrl < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :open_id_url, :string
  end

  def self.down
    remove_column :users, :open_id_url
  end
end
