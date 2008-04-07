class CreatedAt < ActiveRecord::Migration
  # Current bug in Rails that prevents rename_column working in SQLite
  # if the column names use symbols instead of strings.
  # <http://dev.rubyonrails.org/changeset/2731>
  def self.up
    rename_column :todos, 'created', 'created_at'
  end

  def self.down
    rename_column :todos, 'created_at', 'created'
  end
end
