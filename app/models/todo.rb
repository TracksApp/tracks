class Todo < ActiveRecord::Base

  after_save :save_predecessors

  # relations
  belongs_to :context
  belongs_to :project
  belongs_to :user
  belongs_to :recurring_todo

  has_many :predecessor_dependencies, :foreign_key => 'predecessor_id', :class_name => 'Dependency', :dependent => :destroy
  has_many :successor_dependencies,   :foreign_key => 'successor_id',   :class_name => 'Dependency', :dependent => :destroy
  has_many :predecessors, :through => :successor_dependencies
  has_many :successors,   :through => :predecessor_dependencies
  has_many :uncompleted_predecessors, :through => :successor_dependencies,
    :source => :predecessor, :conditions => ['NOT (todos.state = ?)', 'completed']
  has_many :pending_successors, :through => :predecessor_dependencies,
    :source => :successor, :conditions => ['todos.state = ?', 'pending']

  # scopes for states of this todo
  named_scope :active, :conditions => { :state => 'active' }
  named_scope :active_or_hidden, :conditions => ["todos.state = ? OR todos.state = ?", 'active', 'project_hidden']
  named_scope :not_completed, :conditions =>  ['NOT (todos.state = ?)', 'completed']
  named_scope :completed, :conditions =>  ["NOT (todos.completed_at IS NULL)"]
  named_scope :deferred, :conditions => ["todos.completed_at IS NULL AND NOT (todos.show_from IS NULL)"]
  named_scope :blocked, :conditions => ['todos.state = ?', 'pending']
  named_scope :pending, :conditions => ['todos.state = ?', 'pending']
  named_scope :deferred_or_blocked, :conditions => ["(todos.completed_at IS NULL AND NOT(todos.show_from IS NULL)) OR (todos.state = ?)", "pending"]
  named_scope :not_deferred_or_blocked, :conditions => ["todos.completed_at IS NULL AND todos.show_from IS NULL AND NOT(todos.state = ?)", "pending"]
  named_scope :hidden,
    :joins => "INNER JOIN contexts c_hidden ON c_hidden.id = todos.context_id",
    :conditions => ["todos.state = ? OR (c_hidden.hide = ? AND (todos.state = ? OR todos.state = ? OR todos.state = ?))",
    'project_hidden', true, 'active', 'deferred', 'pending']
  named_scope :not_hidden,
    :joins => "INNER JOIN contexts c_hidden ON c_hidden.id = todos.context_id",
    :conditions => ['NOT(todos.state = ? OR (c_hidden.hide = ? AND (todos.state = ? OR todos.state = ? OR todos.state = ?)))',
    'project_hidden', true, 'active', 'deferred', 'pending']

  # other scopes
  named_scope :are_due, :conditions => ['NOT (todos.due IS NULL)']
  named_scope :with_tag, lambda { |tag_id| {:joins => :taggings, :conditions => ["taggings.tag_id = ? ", tag_id] } }
  named_scope :with_tags, lambda { |tag_ids| {:conditions => ["EXISTS(SELECT * from taggings t WHERE t.tag_id IN (?) AND t.taggable_id=todos.id AND t.taggable_type='Todo')", tag_ids] } }
  named_scope :of_user, lambda { |user_id| {:conditions => ["todos.user_id = ? ", user_id] } }
  named_scope :completed_after, lambda { |date| {:conditions => ["todos.completed_at > ?", date] } }
  named_scope :completed_before, lambda { |date| {:conditions => ["todos.completed_at < ?", date] } }
  named_scope :created_after, lambda { |date| {:conditions => ["todos.created_at > ?", date] } }
  named_scope :created_before, lambda { |date| {:conditions => ["todos.created_at < ?", date] } }

  STARRED_TAG_NAME = "starred"
  DEFAULT_INCLUDES = [ :project, :context, :tags, :taggings, :pending_successors, :uncompleted_predecessors, :recurring_todo ]

  # state machine
  include AASM
  aasm_column :state
  aasm_initial_state Proc.new { |t| (t.show_from && t.user && (t.show_from > t.user.date)) ? :deferred : :active}

  aasm_state :active
  aasm_state :project_hidden
  aasm_state :completed, :enter => Proc.new { |t| t.completed_at = Time.zone.now }, :exit => Proc.new { |t| t.completed_at = nil}
  aasm_state :deferred, :exit => Proc.new { |t| t[:show_from] = nil }
  aasm_state :pending

  aasm_event :defer do
    transitions :to => :deferred, :from => [:active]
  end

  aasm_event :complete do
    transitions :to => :completed, :from => [:active, :project_hidden, :deferred, :pending]
  end

  aasm_event :activate do
    transitions :to => :active, :from => [:project_hidden, :deferred]
    transitions :to => :active, :from => [:completed], :guard => :no_uncompleted_predecessors?
    transitions :to => :active, :from => [:pending], :guard => :no_uncompleted_predecessors_or_deferral?
    transitions :to => :pending, :from => [:completed], :guard => :uncompleted_predecessors?
    transitions :to => :deferred, :from => [:pending], :guard => :no_uncompleted_predecessors?
  end

  aasm_event :hide do
    transitions :to => :project_hidden, :from => [:active, :deferred, :pending]
  end

  aasm_event :unhide do
    transitions :to => :deferred, :from => [:project_hidden], :guard => Proc.new{|t| !t.show_from.blank? }
    transitions :to => :pending, :from => [:project_hidden], :guard => :uncompleted_predecessors?
    transitions :to => :active, :from => [:project_hidden]
  end

  aasm_event :block do
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
    @removed_predecessors = nil
  end

  def no_uncompleted_predecessors_or_deferral?
    no_deferral = show_from.blank? or Time.zone.now > show_from
    return (no_deferral && no_uncompleted_predecessors?)
  end

  def no_uncompleted_predecessors?
    return !uncompleted_predecessors?
  end

  def uncompleted_predecessors?
    return !uncompleted_predecessors.all(true).empty?
  end

  # Returns a string with description <context, project>
  def specification
    project_name = self.project.is_a?(NullProject) ? "(none)" : self.project.name
    return "\'#{self.description}\' <\'#{self.context.title}\'; \'#{project_name}\'>"
  end

  def validate
    if !show_from.blank? && show_from < user.date
      errors.add("show_from", I18n.t('models.todo.error_date_must_be_future'))
    end
    errors.add(:description, "may not contain \" characters") if /\"/.match(self.description)
    unless @predecessor_array.nil? # Only validate predecessors if they changed
      @predecessor_array.each do |todo|
        errors.add("Depends on:", "Adding '#{h(todo.specification)}' would create a circular dependency") if is_successor?(todo)
      end
    end
  end

  def save_predecessors
    unless @predecessor_array.nil?  # Only save predecessors if they changed
      current_array = self.predecessors
      remove_array = current_array - @predecessor_array
      add_array = @predecessor_array - current_array

      @removed_predecessors = []
      remove_array.each do |todo|
        unless todo.nil?
          @removed_predecessors << todo
          self.predecessors.delete(todo)
        end
      end

      add_array.each do |todo|
        unless todo.nil?
          self.predecessors << todo unless self.predecessors.include?(todo)
        else
          logger.error "Could not find #{todo.description}" # Unexpected since validation passed
        end
      end
    end
  end

  def removed_predecessors
    return @removed_predecessors
  end

  def remove_predecessor(predecessor)
    # remove predecessor and activate myself
    self.predecessors.delete(predecessor)
    self.activate!
  end

  # Returns true if t is equal to self or a successor of self
  def is_successor?(todo)
    if self == todo
      return true
    elsif self.successors.empty?
      return false
    else
      self.successors.each do |item|
        if item.is_successor?(todo)
          return true
        end
      end
    end
    return false
  end

  def has_pending_successors
    return !pending_successors.empty?
  end

  def has_tag?(tag_name)
    return self.tags.any? {|tag| tag.name == tag_name}
  end

  def hidden?
    return self.state == 'project_hidden' || ( self.context.hidden? && (self.state == 'active' || self.state == 'deferred'))
  end

  def update_state_from_project
    if self.state == 'project_hidden' and !self.project.hidden?
      if self.uncompleted_predecessors.empty?
        self.state = 'active'
      else
        self.state = 'pending'
      end
    elsif self.state == 'active' and self.project.hidden?
      self.state = 'project_hidden'
    end
    self.save!
  end

  def toggle_completion!
    return completed? ? activate! : complete!
  end

  def show_from
    self[:show_from]
  end

  def show_from=(date)
    # parse Date objects into the proper timezone
    date = user.at_midnight(date) if (date.is_a? Date)

    # show_from needs to be set before state_change because of "bug" in aasm.
    # If show_from is not set, the todo will not validate and thus aasm will not save
    # (see http://stackoverflow.com/questions/682920/persisting-the-state-column-on-transition-using-rubyist-aasm-acts-as-state-machi)
    self[:show_from] = date

    activate! if deferred? && date.blank?
    defer! if active? && !date.blank? && date > user.date
  end

  def self.feed_options(user)
    {
      :title => 'Tracks Actions',
      :description => "Actions for #{user.display_name}"
    }
  end

  def starred?
    return has_tag?(STARRED_TAG_NAME)
  end

  def toggle_star!
    self.starred= !starred?
  end

  def starred=(starred)
    if starred
      _add_tags STARRED_TAG_NAME unless starred?
    else
      _remove_tags STARRED_TAG_NAME
    end
    starred
  end

  def from_recurring_todo?
    return self.recurring_todo_id != nil
  end

  def add_predecessor_list(predecessor_list)
    return unless predecessor_list.kind_of? String

    @predecessor_array=predecessor_list.split(",").inject([]) do |list, todo_id|
      predecessor = self.user.todos.find_by_id( todo_id.to_i ) unless todo_id.blank?
      list <<  predecessor unless predecessor.nil?
      list
    end

    return @predecessor_array
  end

  def add_predecessor(t)
    return if t.nil?

    @predecessor_array = predecessors
    @predecessor_array << t
  end

  # activate todos that should be activated if the current todo is completed
  def activate_pending_todos
    pending_todos = successors.find_all {|t| t.uncompleted_predecessors.empty?}
    pending_todos.each {|t| t.activate! }
    return pending_todos
  end

  # Return todos that should be blocked if the current todo is undone
  def block_successors
    active_successors = successors.find_all {|t| t.active? or t.deferred?}
    active_successors.each {|t| t.block!}
    return active_successors
  end

  def raw_notes=(value)
    self[:notes] = value
  end

  # XML API fixups
  def predecessor_dependencies=(params)
    value = params[:predecessor]
    return if value.nil?

    # for multiple dependencies, value will be an array of id's, but for a single dependency,
    # value will be a string. In that case convert to array
    value = [value] unless value.class == Array

    value.each { |ele| add_predecessor(self.user.todos.find_by_id(ele.to_i)) unless ele.blank? }
  end

  alias_method :original_context=, :context=
  def context=(value)
    if value.is_a? Context
      self.original_context=(value)
    else
      c = Context.find_by_name(value[:name])
      c = Context.create(value) if c.nil?
      self.original_context=(c)
    end
  end

  alias_method :original_project, :project
  def project
    original_project.nil? ? Project.null_object : original_project
  end

  alias_method :original_project=, :project=
  def project=(value)
    if value.is_a? Project
      self.original_project=(value)
    elsif !(value.nil? || value.is_a?(NullProject))
      p = Project.find_by_name(value[:name])
      p = Project.create(value) if p.nil?
      self.original_project=(p)
    else
      self.original_project=value
    end
  end

  # used by the REST API. <tags> will also work, this is renamed to add_tags in TodosController::TodoCreateParamsHelper::initialize
  def add_tags=(params)
    tag_with params[:tag].inject([]) { |list, value| list << value[:name] } unless params[:tag].nil?
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
      found_context = user.contexts.active.find_by_namepart(context)
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
        found_project = user.projects.active.find_by_namepart(project)
        found_project = user.projects.find_by_namepart(project) if found_project.nil?
      end
      project_id = found_project.id unless found_project.nil?
    end

    todo = user.todos.build
    todo.description = description
    todo.raw_notes = notes
    todo.context_id = context_id
    todo.project_id = project_id unless project_id.nil?
    return todo
  end

end
