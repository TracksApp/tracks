class AddLastReviewedToProject < ActiveRecord::Migration

  def self.up
      add_column :projects, :last_reviewed, :timestamp
      execute 'UPDATE projects SET last_reviewed = created_at WHERE last_reviewed IS NULL'
  end

  def self.down
      remove_column :projects, :last_reviewed
  end
end
