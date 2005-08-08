class Notes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :user_id,        :integer,     :null => false
      t.column :project_id,     :integer,     :null => false
      t.column :body,           :text
      t.column :created_at,     :datetime,    :default => '0000-00-00 00:00:00'
      t.column :updated_at,     :datetime,    :default => '0000-00-00 00:00:00'
    end
  end

  def self.down
    drop_table :notes
  end
end
