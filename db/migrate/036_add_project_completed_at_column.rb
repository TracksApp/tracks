class AddProjectCompletedAtColumn < ActiveRecord::Migration

  class Project < ActiveRecord::Base; end

  def self.up
    add_column :projects, :completed_at, :datetime
    @projects = Project.all
    @projects.select{ |project| project.state == 'completed'}.each do |project|
      project.completed_at = project.updated_at
      project.save
    end
  end

  def self.down
    remove_column :projects, :completed_at
  end
end
