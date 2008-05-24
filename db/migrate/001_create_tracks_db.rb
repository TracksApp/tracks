# Verision 1.0.3 database
class CreateTracksDb < ActiveRecord::Migration
  def self.up
    create_table :contexts do |t|
      t.column :name,           :string,      :null => false
      t.column :position,       :integer,    :null => false
      t.column :hide,           :boolean,     :default => false
    end

    create_table :projects do |t|
      t.column :name,           :string,      :null => false
      t.column :position,       :integer,    :null => false
      t.column :done,           :boolean,     :default => false
    end

    create_table :todos do |t|
      t.column :context_id,     :integer,    :null => false
      t.column :project_id,     :integer
      t.column :description,    :string,      :null => false
      t.column :notes,          :text
      t.column :done,           :boolean,     :default => false, :null => false
      t.column :created,        :datetime
      t.column :due,            :date
      t.column :completed,      :datetime
    end

    create_table :users do |t|
      t.column :login,           :string,      :limit => 80, :null => false
      t.column :password,        :string,      :limit => 40, :null => false
      t.column :word,            :string
      t.column :is_admin,        :boolean,     :default => false, :null => false
    end
  end

  def self.down
    drop_table :contexts
    drop_table :projects
    drop_table :todos
    drop_table :users
  end
end
