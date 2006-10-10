class ConvertProjectToStateMachine < ActiveRecord::Migration

  class Project < ActiveRecord::Base; end

  def self.up
    ActiveRecord::Base.transaction do
      add_column :projects, :state, :string, :limit => 20, :default => "active", :null => false
      @projects = Project.find(:all)
      @projects.each do |project|
        project.state = project.done ? 'completed' : 'active'
        project.save
      end
      remove_column :projects, :done
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      add_column :projects, :done, :integer, :limit => 4, :default => 0, :null => false
      @projects = Project.find(:all)
      @projects.each do |project|
        project.done = project.state == 'completed'
        project.save
      end
      remove_column :projects, :state
    end
  end
end
