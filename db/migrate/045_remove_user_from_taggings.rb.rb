class RemoveUserFromTaggings < ActiveRecord::Migration
  def self.up
    remove_column :taggings, :user_id
  end

  def self.down
    add_column :taggings, :user_id, :integer
  end
end