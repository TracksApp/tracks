class UpgradeOpenId < ActiveRecord::Migration
  def self.up
    create_table :open_id_authentication_associations, :force => true do |t|
      t.integer :issued, :lifetime
      t.string :handle, :assoc_type
      t.binary :server_url, :secret
    end

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :timestamp, :null => false
      t.string :server_url, :null => true
      t.string :salt, :null => false
    end
    
    drop_table :open_id_associations
    drop_table :open_id_nonces
    drop_table :open_id_settings
  end

  def self.down
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces

    create_table "open_id_associations", :force => true do |t|
      t.binary  "server_url"
      t.string  "handle"
      t.binary  "secret"
      t.integer "issued"
      t.integer "lifetime"
      t.string  "assoc_type"
    end

    create_table "open_id_nonces", :force => true do |t|
      t.string  "nonce"
      t.integer "created"
    end

    create_table "open_id_settings", :force => true do |t|
      t.string "setting"
      t.binary "value"
    end
  end
end
