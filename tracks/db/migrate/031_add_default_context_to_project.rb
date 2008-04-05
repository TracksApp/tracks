class AddDefaultContextToProject < ActiveRecord::Migration
  def self.up
     add_column :projects, :default_context_id, :integer
  end

  def self.down
    remove_column :projects, :default_context_id
  end
end
