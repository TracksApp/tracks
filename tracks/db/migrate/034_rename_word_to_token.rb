class RenameWordToToken < ActiveRecord::Migration
  def self.up
    rename_column :users, :word, :token
  end

  def self.down
    rename_column :users, :token, :word
  end
end
