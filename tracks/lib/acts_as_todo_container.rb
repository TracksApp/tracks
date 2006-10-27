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
        
        def not_done_todos
          @not_done_todos = self.find_not_done_todos if @not_done_todos == nil
          @not_done_todos
        end

        def done_todos
          @done_todos = self.find_done_todos if @done_todos == nil
          @done_todos
        end

        def find_not_done_todos
          todos = Todo.find(:all,
                            :conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? and todos.type = ? and todos.done = ?", id, "Immediate", false],
                            :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
                            :include => find_todos_include)

        end

        def find_done_todos
          todos = Todo.find :all, :conditions => ["todos.#{self.class.base_class.name.singularize.downcase}_id = ? AND todos.type = ? AND todos.done = ?", id, "Immediate", true],
                            :order => "completed DESC",
                            :include => find_todos_include,
                            :limit => @user.preference.show_number_completed
        end
        
      end
      
              
    end
  end
end
