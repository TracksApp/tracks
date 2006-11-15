module Tracks
  module Acts #:nodoc:
    module TodoContainer #:nodoc:
      
      # This act provides the capabilities for finding todos that belong to the entity
      
      def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
      
      module ActMacro
        def acts_as_todo_container(opts = {})
          
          opts[:find_todos_include] = [] unless opts.key?(:find_todos_include)
          opts[:find_todos_include] = [opts[:find_todos_include]] unless opts[:find_todos_include].is_a?(Array)
          write_inheritable_attribute :find_todos_include, [base_class.name.singularize.downcase] + opts[:find_todos_include]
          
          class_inheritable_reader    :find_todos_include
          
          class_eval "include Tracks::Acts::TodoContainer::InstanceMethods"
        end
      end
      
      module InstanceMethods
        
        def not_done_todos(opts={})
          @not_done_todos = self.find_not_done_todos(opts) if @not_done_todos == nil
          @not_done_todos
        end

        def done_todos
          @done_todos = self.find_done_todos if @done_todos == nil
          @done_todos
        end

        def find_not_done_todos(opts={})
          where_state_sql = "todos.state = 'active'"
          if opts.has_key?(:include_project_hidden_todos) && (opts[:include_project_hidden_todos] == true)
            where_state_sql = "(todos.state = 'active' or todos.state = 'project_hidden')"
          end
          todos = Todo.find(:all,
                            :conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? and #{where_state_sql}", id],
                            :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
                            :include => find_todos_include)

        end

        def find_done_todos
          todos = Todo.find(:all, :conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? AND todos.state = ?", id, "completed"],
                            :order => "completed_at DESC",
                            :include => find_todos_include,
                            :limit => @user.preference.show_number_completed)
        end
        
        def not_done_todo_count(opts={})
          where_state_sql = "todos.state = 'active'"
          if opts.has_key?(:include_project_hidden_todos) && (opts[:include_project_hidden_todos] == true)
            where_state_sql = "(todos.state = 'active' or todos.state = 'project_hidden')"
          end
          Todo.count(:conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? and #{where_state_sql}", id],
                      :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
                      :include => find_todos_include)

        end

        def done_todo_count
          Todo.count(:conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? AND todos.state = ?", id, "completed"],
                      :order => "completed_at DESC",
                      :include => find_todos_include,
                      :limit => @user.preference.show_number_completed)
        end
        
      end
      
              
    end
  end
end
