class AddDefaultTagsToProject < ActiveRecord::Migration[5.2]
  def self.up
    add_column :projects, :default_tags, :string
  end

  def self.down
    remove_column :projects, :default_tags
  end
end
