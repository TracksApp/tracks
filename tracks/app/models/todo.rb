class Todo < ActiveRecord::Base
  require 'validations'

  belongs_to :context, :order => 'name'
  belongs_to :project
  belongs_to :user
  
  acts_as_state_machine :initial => :active, :column => 'state'
  
  state :active, :enter => Proc.new { |t| t.show_from = nil }
  state :project_hidden
  state :completed, :enter => Proc.new { |t| t.completed_at = Time.now() }, :exit => Proc.new { |t| t.completed_at = nil }
  state :deferred

  event :defer do
    transitions :to => :deferred, :from => [:active]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :project_hidden, :deferred]
  end
  
  event :activate do
    transitions :to => :active, :from => [:project_hidden, :completed, :deferred]
  end
    
  event :hide do
    transitions :to => :project_hidden, :from => [:active, :deferred]
  end
  
  event :unhide do
    transitions :to => :deferred, :from => [:project_hidden], :guard => Proc.new{|t| t.show_from != nil}
    transitions :to => :active, :from => [:project_hidden]
  end
  
  attr_protected :user

  # Description field can't be empty, and must be < 100 bytes
  # Notes must be < 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true 
  # validates_chronic_date :due, :allow_nil => true
  validates_presence_of :show_from, :if => :deferred?
  
  def validate
    if deferred? && show_from != nil && show_from < Date.today()
      errors.add("Show From", "must be a date in the future.")
    end
  end
  
  def toggle_completion
    if completed?
      activate!
    else
      complete!
    end
  end

  alias_method :original_project, :project

  def project
    original_project.nil? ? Project.null_object : original_project
  end
  
  def self.new_deferred
    todo = self.new
    def todo.set_initial_state
      self.state = 'deferred'
    end
    todo
  end
  
  def self.not_done( id=id )
    self.find(:all, :conditions =>[ "done = ? AND context_id = ?", false, id], :order =>"due IS NULL, due ASC, created_at ASC")
  end
  
  def self.find_completed(user_id)
    done = self.find(:all,
                     :conditions => ['todos.user_id = ? and todos.state = ? and todos.completed_at is not null', user_id, 'completed'],
                     :order => 'todos.completed_at DESC',
                     :include => [ :project, :context ])
                     
    def done.completed_within( date )
      reject { |x| x.completed_at < date }
    end

    def done.completed_more_than( date )
      reject { |x| x.completed_at > date }
    end
    
    done

  end
  
end
