class Todo < ActiveRecord::Base
  require 'validations'

  belongs_to :context, :order => 'name'
  belongs_to :project
  belongs_to :user
  
  acts_as_taggable
  acts_as_state_machine :initial => :active, :column => 'state'
  
  state :active, :enter => Proc.new { |t| t[:show_from] = nil }
  state :project_hidden
  state :completed, :enter => Proc.new { |t| t.completed_at = Time.now.utc }, :exit => Proc.new { |t| t.completed_at = nil }
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
    transitions :to => :deferred, :from => [:project_hidden], :guard => Proc.new{|t| !t.show_from.blank? }
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
  validates_presence_of :context
  
  def validate
    if deferred? && !show_from.blank? && show_from < Time.now.utc.to_date
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
  
  def activate_and_save!
    activate!
    save!
  end

  def show_from=(date)
    activate! if deferred? && date.blank?
    defer! if active? && !date.blank? && date > Time.now.utc.to_date
    self[:show_from] = date 
  end

  alias_method :original_project, :project

  def project
    original_project.nil? ? Project.null_object : original_project
  end
  
  alias_method :original_set_initial_state, :set_initial_state
  
  def set_initial_state
    if show_from && (show_from > Time.now.utc.to_date)
      write_attribute self.class.state_column, 'deferred'
    else
      original_set_initial_state
    end
  end
      
end