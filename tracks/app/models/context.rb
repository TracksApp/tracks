class Context < ActiveRecord::Base

    acts_as_list
    has_many :todo, :dependent => true
    
    # Context name must not be empty
    # and must be less than 255 bytes
    validates_presence_of :name, :message => "context must have a name"
    validates_length_of :name, :maximum => 255, :message => "context name must be less than %d"
    validates_uniqueness_of :name, :message => "already exists"
    
    def self.list_of(hidden=0)
     find(:all, :conditions => [ "hide = ?" , hidden ], :order => "position ASC")
    end
    
    # Returns a count of next actions in the given context
    # The result is count and a string descriptor, correctly pluralised if there are no
    # actions or multiple actions
    #
    def count_undone_todos(string="actions")
      count = Todo.count( "context_id=#{self.id} AND done=0" )
      
      if count == 1
        word = string.singularize
      else
        word = string.pluralize
      end
        return count.to_s + " " + word
    end
      
end
