class CreateCitationsItems < ActiveRecord::Migration
  def self.up
    create_table :citations_items do |t|
      t.integer :citation_id, :null => false
      t.integer :item_id, :null => false
      t.string :item_type, :null => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :citations_items
  end
end
