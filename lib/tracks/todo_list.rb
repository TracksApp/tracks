module Tracks
  module TodoList
    # TODO: this module should be deprecated. This could mostly (all?) be replaced by named scopes)
        
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
      with_not_done_scope(opts) do
        self.todos.find(:all, :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC")
      end
    end
    
    def find_deferred_todos(opts={})
      self.todos.find_in_state(:all, :deferred, :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC")
    end

    def find_done_todos
      self.todos.find_in_state(:all, :completed, :order => "todos.completed_at DESC", :limit => self.user.prefs.show_number_completed)
    end
  
    def not_done_todo_count(opts={})
      with_not_done_scope(opts) do
        self.todos.count
      end
    end
    
    def with_not_done_scope(opts={})
      conditions = ["todos.state = ?", 'active']
      if opts.has_key?(:include_project_hidden_todos) && (opts[:include_project_hidden_todos] == true)
        conditions = ["(todos.state = ? OR todos.state = ?)", 'active', 'project_hidden']
      end
      if opts.has_key?(:tag)
        conditions = ["todos.state = ? AND taggings.tag_id = ?", 'active', opts[:tag]]
      end
      self.todos.send :with_scope, :find => {:conditions => conditions, :include => [:taggings]} do
        yield
      end
    end

    def done_todo_count
      self.todos.count_in_state(:completed)
    end
  
    def deferred_todo_count
      self.todos.count_in_state(:deferred)
    end
  
  end
end
