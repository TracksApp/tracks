module Tracks
  module TodoList
        
    def not_done_todos(opts={})
      @not_done_todos ||= self.find_not_done_todos(opts)
    end

    def done_todos
      @done_todos ||= self.find_done_todos
    end
    
    def deferred_todos
      @deferred_todos ||= self.find_deferred_todos
    end

    def find_not_done_todos(opts={})
      self.todos.find(:all, :conditions => not_done_conditions(opts),
                      :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC")
    end
    
    def find_deferred_todos(opts={})
      self.todos.find(:all, :conditions => ["todos.state = ?", "deferred"],
                      :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC")
    end

    def not_done_conditions(opts)
      conditions = ["todos.state = ?", 'active']
      if opts.has_key?(:include_project_hidden_todos) && (opts[:include_project_hidden_todos] == true)
        conditions = ["(todos.state = ? or todos.state = ?)", 'active', 'project_hidden']
      end
      conditions
    end

    def find_done_todos
      self.todos.find(:all, :conditions => ["todos.state = ?", "completed"],
                      :order => "todos.completed_at DESC", :limit => self.user.preference.show_number_completed)                        
    end
  
    def not_done_todo_count(opts={})
      self.todos.count(not_done_conditions(opts))
    end

    def done_todo_count
      self.todos.count_in_state(:completed)
    end
  
  end
end
