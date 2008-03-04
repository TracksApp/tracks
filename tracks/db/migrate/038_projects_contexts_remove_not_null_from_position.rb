class ProjectsContextsRemoveNotNullFromPosition < ActiveRecord::Migration
  def self.up
    change_column :projects, :position, :string, :null => true
    change_column :contexts, :position, :string, :null => true
  end

  def self.down
    @projects = Project.find(:all)
    @projects.each do |project|
      project.position = 0 if !project.position?
      project.save
    end
    change_column :projects, :position, :string, :null => false

    @contexts = Context.find(:all)
    @contexts.each do |context|
      context.position = 0 if !context.position?
      context.save
    end
    change_column :contexts, :position, :string, :null => false
  end
end
