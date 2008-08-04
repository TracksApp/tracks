class AddSeveralIndexes < ActiveRecord::Migration
  def self.up
    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, :tag_id
    add_index :recurring_todos, :user_id
    add_index :recurring_todos, :state
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type]
    remove_index :taggings, :tag_id
    remove_index :recurring_todos, :user_id
    remove_index :recurring_todos, :state
  end
end
