class FixIncorrectlyHiddenTodos < ActiveRecord::Migration
  def self.up
    hidden_todos_without_project =
      Todo.find(:all, :conditions => "state='project_hidden' AND project_id IS NULL")
    
    active_projects = Project.find(:all, :conditions => "state='active'")
    hidden_todos_in_active_projects =
      Todo.find(:all, :conditions => ["state='project_hidden' AND project_id IN (?)", active_projects])
    
    todos_to_fix = hidden_todos_without_project + hidden_todos_in_active_projects
    todos_to_fix.each do |todo|
      todo.update_attribute :state, 'active'
    end
  end

  def self.down
  end
end
