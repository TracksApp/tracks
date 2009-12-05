class AddTodoDependencies < ActiveRecord::Migration
  def self.up
    create_table :dependencies do |t|
      t.integer :successor_id,     :null => false
      t.integer :predecessor_id,   :null => false
      t.string  :relationship_type
    end
  end
  
  def self.down
    drop_table :dependencies
  end
end
