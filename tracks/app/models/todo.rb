class Todo < ActiveRecord::Base
  require 'validations'

  belongs_to :context, :order => 'name'
  belongs_to :project
  belongs_to :user
  
  attr_protected :user

  # Description field can't be empty, and must be < 100 bytes
  # Notes must be < 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true 
  # validates_chronic_date :due, :allow_nil => true

  alias_method :original_project, :project

  def project
    original_project.nil? ? Project.null_object : original_project
  end
  
  def self.not_done( id=id )
    self.find(:all, :conditions =>[ "done = ? AND context_id = ?", false, id], :order =>"due IS NULL, due ASC, created_at ASC")
  end
  
  def self.find_completed(user_id)
    done = self.find(:all,
                     :conditions => ['todos.user_id = ? and todos.done = ? and todos.completed is not null', user_id, true],
                     :order => 'todos.completed DESC',
                     :include => [ :project, :context ])
                     
    def done.completed_within( date )
      reject { |x| x.completed < date }
    end

    def done.completed_more_than( date )
      reject { |x| x.completed > date }
    end
    
    done

  end
  
end
