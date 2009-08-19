class Todo < ActiveRecord::Base

  belongs_to :context
  belongs_to :project
  belongs_to :user
  belongs_to :recurring_todo
  
  has_many :predecessor_dependencies, :foreign_key => 'predecessor_id', :class_name => 'Dependency', :dependent => :destroy
  has_many :successor_dependencies,   :foreign_key => 'successor_id',   :class_name => 'Dependency', :dependent => :destroy
  has_many :predecessors, :through => :successor_dependencies
  has_many :successors,   :through => :predecessor_dependencies
  has_many :uncompleted_predecessors, :through => :successor_dependencies,
           :source => :predecessor, :conditions => ['NOT (state = ?)', 'completed']
  has_many :pending_successors, :through => :predecessor_dependencies,
           :source => :successor, :conditions => ['state = ?', 'pending']
  
  after_save :save_predecessors

  named_scope :active, :conditions => { :state => 'active' }
  named_scope :not_completed, :conditions =>  ['NOT (state = ? )', 'completed']
  named_scope :are_due, :conditions => ['NOT (todos.due IS NULL)']

  STARRED_TAG_NAME = "starred"
  
  acts_as_state_machine :initial => :active, :column => 'state'
  
  # when entering active state, also remove completed_at date. Looks like :exit
  # of state completed is not run, see #679
  state :active, :enter => Proc.new { |t| t[:show_from], t.completed_at = nil, nil }
  state :project_hidden
  state :completed, :enter => Proc.new { |t| t.completed_at = Time.zone.now }, :exit => Proc.new { |t| t.completed_at = nil }
  state :deferred
  state :pending

  event :defer do
    transitions :to => :deferred, :from => [:active]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :project_hidden, :deferred]
  end
  
  event :activate do
    transitions :to => :active, :from => [:project_hidden, :completed, :deferred]
    transitions :to => :active, :from => [:pending], :guard => :no_uncompleted_predecessors_or_deferral? 
    transitions :to => :deferred, :from => [:pending], :guard => :no_uncompleted_predecessors?
  end
    
  event :hide do
    transitions :to => :project_hidden, :from => [:active, :deferred]
  end
  
  event :unhide do
    transitions :to => :deferred, :from => [:project_hidden], :guard => Proc.new{|t| !t.show_from.blank? }
    transitions :to => :active, :from => [:project_hidden]
  end
  
  event :block do
    transitions :to => :pending, :from => [:active, :deferred]
  end
    
  attr_protected :user

  # Description field can't be empty, and must be < 100 bytes Notes must be <
  # 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true 
  validates_presence_of :show_from, :if => :deferred?
  validates_presence_of :context
  
  def initialize(*args)
    super(*args)
    @predecessor_array = nil # Used for deferred save of predecessors
  end
  
  def no_uncompleted_predecessors_or_deferral?
    return (show_from.blank? or Time.zone.now > show_from and uncompleted_predecessors.empty?)
  end
  
  def no_uncompleted_predecessors?
    return uncompleted_predecessors.empty?
  end
  
 
  def todo_from_string(specification)
    # Split specification into parts: description <project, context>
    parts = specification.split(%r{\ \<|; |\>})
    return nil unless parts.length == 3
    todos = Todo.all(:joins => [:project, :context],
                    :include => [:context, :project],
                    :conditions => {:description => parts[0],
                                    :contexts => {:name => parts[2]}})
    return nil if todos.empty?
    # todos now contains all todos with matching description and context
    # TODO: Is this possible to do with a single query?
    todos.each do |todo|
      project_name = todo.project.is_a?(NullProject) ? "(none)" : todo.project.name
      return todo if project_name == parts[1]
    end
    return nil
  end
  
  def validate
    if !show_from.blank? && show_from < user.date
      errors.add("show_from", "must be a date in the future")
    end
    unless @predecessor_array.nil? # Only validate predecessors if they changed
      @predecessor_array.each do |specification|
        t = todo_from_string(specification)
        if t.nil?
          errors.add("Depends on:", "Could not find action '#{h(specification)}'")
        else
          errors.add("Depends on:", "Adding '#{h(specification)}' would create a circular dependency") if is_successor?(t)
        end
      end
    end
  end
  
  # Returns a string with description, project and context
  def specification
    project_name = project.is_a?(NullProject) ? "(none)" : project.name
    return "#{description} <#{project_name}; #{context.title}>"
  end
  
  def save_predecessors
    unless @predecessor_array.nil?  # Only save predecessors if they changed
      current_array = predecessors.map{|p| p.specification}
      remove_array = current_array - @predecessor_array
      add_array = @predecessor_array - current_array
      
      # This is probably a bit naive code...
      remove_array.each do |specification|
        t = todo_from_string(specification)
        self.predecessors.delete(t) unless t.nil?
      end
      # ... as is this?
      add_array.each do |specification|
        t = todo_from_string(specification)
        unless t.nil?
          self.predecessors << t unless self.predecessors.include?(t)
        else
          logger.error "Could not find #{specification}" # Unexpected since validation passed
        end
      end
    end
  end
  
  def remove_predecessor(predecessor)
    # remove predecessor and activate myself
    predecessors.delete(predecessor)
    self.activate!
  end
  
  # Returns true if t is equal to self or a successor of self
  def is_successor?(t)
    if self == t
      return true
    elsif self.successors.empty?
      return false
    else
      self.successors.each do |item|
        if item.is_successor?(t)
          return true
        end
      end
    end
    return false
  end

  def update_state_from_project
    if state == 'project_hidden' and !project.hidden?
      if self.uncompleted_predecessors.empty?
        self.state = 'pending'
      else
        self.state = 'active'
      end
    elsif state == 'active' and project.hidden?
      self.state = 'project_hidden'
    end
  end
 
  def toggle_completion!
    saved = false
    if completed?
      saved = activate!
    else
      saved = complete!
    end
    return saved
  end
  
  def show_from
    self[:show_from]
  end
  
  def show_from=(date)
    # parse Date objects into the proper timezone
    date = user.at_midnight(date) if (date.is_a? Date)
    activate! if deferred? && date.blank?
    defer! if active? && !date.blank? && date > user.date
    self[:show_from] = date 
  end

  alias_method :original_project, :project

  def project
    original_project.nil? ? Project.null_object : original_project
  end

  alias_method :original_set_initial_state, :set_initial_state
  
  def set_initial_state
    if show_from && (show_from > user.date)
      write_attribute self.class.state_column, 'deferred'
    else
      original_set_initial_state
    end
  end
  
  alias_method :original_run_initial_state_actions, :run_initial_state_actions
  
  def run_initial_state_actions
    # only run the initial state actions if the standard initial state hasn't
    # been changed
    if self.class.initial_state.to_sym == current_state
      original_run_initial_state_actions
    end
  end

  def self.feed_options(user)
    {
      :title => 'Tracks Actions',
      :description => "Actions for #{user.display_name}"
    }
  end
  
  def starred?
    tags.any? {|tag| tag.name == STARRED_TAG_NAME}
  end
  
  def toggle_star!
    if starred?
      _remove_tags STARRED_TAG_NAME
      tags.reload
    else
      _add_tags(STARRED_TAG_NAME)
      tags.reload
    end 
    starred?  
  end

  def from_recurring_todo?
    return self.recurring_todo_id != nil
  end
  
  # TODO: DELIMITER
  # TODO: Should possibly handle state changes also?
  def add_predecessor_list(predecessor_list)
    if predecessor_list.kind_of? String
      @predecessor_array = predecessor_list.split(',').map do |description| 
        description.strip.squeeze(" ")            
      end
    end
  end
  
  def add_predecessor(t)
    @predecessor_array = predecessors.map{|p| p.specification}
    @predecessor_array << t.specification
  end
  
  # Return todos that should be activated if the current todo is completed
  def pending_to_activate
    return successors.find_all {|t| t.uncompleted_predecessors.empty?}
  end
  
  # Return todos that should be blocked if the current todo is undone
  def active_to_block
    return successors.find_all {|t| t.active? or t.deferred?}
  end
  
  # Rich Todo API
  
  def self.from_rich_message(user, default_context_id, description, notes)
    fields = description.match(/([^>@]*)@?([^>]*)>?(.*)/)
    description = fields[1].strip
    context = fields[2].strip
    project = fields[3].strip
    
    context = nil if context == ""
    project = nil if project == ""

    context_id = default_context_id
    unless(context.nil?)
      found_context = user.active_contexts.find_by_namepart(context)
      found_context = user.contexts.find_by_namepart(context) if found_context.nil?
      context_id = found_context.id unless found_context.nil?
    end
    
    unless user.contexts.exists? context_id
      raise(CannotAccessContext, "Cannot access a context that does not belong to this user.")
    end
    
    project_id = nil
    unless(project.blank?)
      if(project[0..3].downcase == "new:")
        found_project = user.projects.build
        found_project.name = project[4..255+4].strip
        found_project.save!
      else
        found_project = user.active_projects.find_by_namepart(project)
        found_project = user.projects.find_by_namepart(project) if found_project.nil?
      end
      project_id = found_project.id unless found_project.nil?
    end
    
    todo = user.todos.build
    todo.description = description
    todo.notes = notes
    todo.context_id = context_id
    todo.project_id = project_id unless project_id.nil?
    return todo
  end
end
