class ProjectsContextsRemoveNotNullFromPosition < ActiveRecord::Migration
  def self.up
    change_column :projects, :position, :integer, {:null => true, :default => false}
    change_column :contexts, :position, :integer, {:null => true, :default => false}
  end

  def self.down
    @projects = Project.find(:all)
    @projects.each do |project|
      project.position = 0 if !project.position?
      project.save
    end
    change_column :projects, :position, :integer, {:null => false, :default => false}

    @contexts = Context.find(:all)
    @contexts.each do |context|
      context.position = 0 if !context.position?
      context.save
    end
    change_column :contexts, :position, :integer, {:null => false, :default => false}
  end
end
