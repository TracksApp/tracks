class Project < ActiveRecord::Base
   
    has_many :todo, :dependent => true
    acts_as_list
    
    # Project name must not be empty
    # and must be less than 255 bytes
    validates_presence_of :name, :message => "project must have a name"
    validates_length_of :name, :maximum => 255, :message => "project name must be less than %d"
    validates_uniqueness_of :name, :message => "already exists"
    
    def self.list_of(isdone=0)
      find(:all, :conditions => [ "done = ?" , isdone ], :order => "position ASC")
    end
    
    def count_undone_todos
        Todo.count( "project_id=#{self.id} AND done=0" )
    end
     
end
