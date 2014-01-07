class FixIncorrectlyHiddenTodos < ActiveRecord::Migration
  def self.up
    hidden_todos_without_project =
      Todo.where(:state => 'project_hidden', :project_id => nil)
    
    active_projects = Project.where(:state => 'active').select("id")
    hidden_todos_in_active_projects =
      Todo.where(:state => 'project_hidden').where("project_id IN (?)", active_projects)
    
    todos_to_fix = hidden_todos_without_project + hidden_todos_in_active_projects
    todos_to_fix.each do |todo|
      todo.update_attribute :state, 'active'
    end
  end

  def self.down
  end
end
