class RemoveUserFromTaggings < ActiveRecord::Migration
  def self.up
    remove_index :taggings, [:tag_id, :taggable_id, :taggable_type]
    remove_index :tags, :name
    remove_column :taggings, :user_id
    add_index :tags, :name
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type]
  end

  def self.down
    remove_index :taggings, [:tag_id, :taggable_id, :taggable_type]
    remove_index :tags, :name
    add_column :taggings, :user_id, :integer
    add_index :tags, :name
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type]
  end

end
