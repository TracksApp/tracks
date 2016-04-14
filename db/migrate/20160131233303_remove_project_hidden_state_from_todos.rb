class RemoveProjectHiddenStateFromTodos < ActiveRecord::Migration
  class Todo < ActiveRecord::Base
    has_many :successor_dependencies, :foreign_key => 'successor_id', :class_name => 'Dependency'
    belongs_to :project
  end

  class Project < ActiveRecord::Base
  end

  class Dependency < ActiveRecord::Base
    belongs_to :predecessor, :foreign_key => 'predecessor_id', :class_name => 'Todo'
  end

  def self.up
    Todo.where(state: 'project_hidden').find_each do |todo|
      if todo.show_from.present?
        todo.state = 'deferred'
      elsif has_uncompleted_predecessor(todo)
        todo.state = 'pending'
      else
        todo.state = 'active'
      end
      todo.save
    end
  end

  def self.down
    Project.where(state: 'hidden').find_each do |project|
      Todo.where(project_id:  project.id).where.not(state: 'completed').find_each do |todo|
        todo.state = 'project_hidden'
        todo.save
      end
    end
  end

  def has_uncompleted_predecessor(todo)
    todo.successor_dependencies.each do |dependency|
      return true unless dependency.predecessor.state == 'completed'
    end
    false
  end
end