class AddTagSupport < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t| 
      t.column :taggable_id, :integer 
      t.column :tag_id, :integer 
      t.column :taggable_type, :string
      t.column :user_id, :integer
    end 
    create_table :tags do |t| 
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    add_index :tags, :name
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type]
  end

  def self.down
    remove_index :taggings, [:tag_id, :taggable_id, :taggable_type]
    remove_index :tags, :name
    drop_table :taggings
    drop_table :tags
  end
end
