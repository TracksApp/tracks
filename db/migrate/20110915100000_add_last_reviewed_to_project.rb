class AddLastReviewedToProject < ActiveRecord::Migration
  def self.up
      add_column :projects, :last_reviewed, :timestamp
      execute 'update projects set last_reviewed = created_at where last_reviewed IS NULL'
  end
  def self.down
      remove_column :projects, :last_reviewed
  end
end
