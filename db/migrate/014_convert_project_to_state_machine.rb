class ConvertProjectToStateMachine < ActiveRecord::Migration

  class Project < ActiveRecord::Base; end

  def self.up
    add_column :projects, :state, :string, :limit => 20, :default => "active", :null => false
    @projects = Project.all
    @projects.each do |project|
      project.state = project.done? ? 'completed' : 'active'
      project.save
    end
    remove_column :projects, :done
  end

  def self.down
    add_column :projects, :done, :integer, :limit => 4, :default => 0, :null => false
    @projects = Project.all
    @projects.each do |project|
      project.done = project.state == 'completed'
      project.save
    end
    remove_column :projects, :state
  end
end
