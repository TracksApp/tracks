class Project < ActiveRecord::Base
   
    has_many :todo, :dependent => true
    acts_as_list
    
    # Project name must not be empty
    # and must be less than 255 bytes
    validates_presence_of :name, :message => "project must have a name"
    validates_length_of :name, :maximum => 255, :message => "project name must be less than %d"
    validates_uniqueness_of :name, :message => "already exists"
	
end
