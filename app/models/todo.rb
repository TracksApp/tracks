class Todo < ApplicationRecord

  MAX_DESCRIPTION_LENGTH = 300
  MAX_NOTES_LENGTH = 60000

  after_save :save_predecessors

  # associations
  belongs_to :context, :touch => true
  belongs_to :project, :touch => true
  belongs_to :user
  belongs_to :recurring_todo

  # Tag association
  include IsTaggable

  # Dependencies associations
  has_many :predecessor_dependencies, :foreign_key => 'predecessor_id', :class_name => 'Dependency', :dependent => :destroy
  has_many :successor_dependencies,   :foreign_key => 'successor_id',   :class_name => 'Dependency', :dependent => :destroy
  has_many :predecessors, :through => :successor_dependencies
  has_many :successors,   :through => :predecessor_dependencies
  has_many :uncompleted_predecessors, -> {where('NOT (todos.state = ?)', 'completed')}, :through => :successor_dependencies,
    :source => :predecessor
  has_many :pending_successors, -> {where('todos.state = ?', 'pending')}, :through => :predecessor_dependencies,
    :source => :successor
  has_many :attachments, dependent: :destroy

  # scopes for states of this todo
  scope :active, -> { active_or_hidden.not_hidden }
  scope :active_or_hidden, -> { where state: 'active' }
  scope :context_hidden, -> { joins('INNER JOIN contexts c ON c.id = todos.context_id').where('c.state = ?', 'hidden') }
  scope :project_hidden, -> { joins('LEFT OUTER JOIN projects p ON p.id = todos.project_id').where('p.state = ?', 'hidden') }
  scope :completed, -> { where 'todos.state = ?', 'completed' }
  scope :deferred, -> { where 'todos.state = ?', 'deferred' }
  scope :blocked, -> {where 'todos.state = ?', 'pending' }
  scope :pending, -> {where 'todos.state = ?', 'pending' }
  scope :deferred_or_blocked, -> { where '(todos.state = ?) OR (todos.state = ?)', 'deferred', 'pending' }
  scope :hidden, -> {
    joins('INNER JOIN contexts c_hidden ON c_hidden.id = todos.context_id').
    joins('LEFT OUTER JOIN projects p_hidden ON p_hidden.id = todos.project_id').
    where('(c_hidden.state = ? OR p_hidden.state = ?)', 'hidden', 'hidden').
    where('NOT todos.state = ?', 'completed') }
  scope :not_hidden, -> { not_context_hidden.not_project_hidden }
  scope :not_deferred_or_blocked, -> { where '(NOT todos.state=?) AND (NOT todos.state = ?)', 'deferred', 'pending' }
  scope :not_project_hidden, -> { joins('LEFT OUTER JOIN projects p ON p.id = todos.project_id').where('p.id IS NULL OR NOT(p.state = ?)', 'hidden') }
  scope :not_context_hidden, -> { joins('INNER JOIN contexts c ON c.id = todos.context_id').where('NOT(c.state = ?)', 'hidden') }
  scope :not_completed, -> { where 'NOT (todos.state = ?)', 'completed' }

  # other scopes
  scope :are_due,           -> { where 'NOT (todos.due IS NULL)' }
  scope :due_today,         -> { where("todos.due <= ?", Time.zone.now) }
  scope :with_tag,          lambda { |tag_id| joins("INNER JOIN taggings ON todos.id = taggings.taggable_id").where("taggings.tag_id = ? AND taggings.taggable_type='Todo'", tag_id) }
  scope :with_tags,         lambda { |tag_ids| where("EXISTS(SELECT * from taggings t WHERE t.tag_id IN (?) AND t.taggable_id=todos.id AND t.taggable_type='Todo')", tag_ids) }
  scope :completed_after,   lambda { |date| where("todos.completed_at > ?", date) }
  scope :completed_before,  lambda { |date| where("todos.completed_at < ?", date) }
  scope :created_after,     lambda { |date| where("todos.created_at > ?", date) }
  scope :created_before,    lambda { |date| where("todos.created_at < ?", date) }
  scope :created_or_completed_after,  lambda { |date| where("todos.created_at > ? or todos.completed_at > ?", date, date) }

  def self.due_after(date)
    where('todos.due > ?', date)
  end

  def self.due_between(start_date, end_date)
    where('todos.due > ? AND todos.due <= ?', start_date, end_date)
  end

  STARRED_TAG_NAME = "starred"
  DEFAULT_INCLUDES = [ :project, :context, :tags, :taggings, :pending_successors, :uncompleted_predecessors, :recurring_todo ]

  # state machine
  include AASM
  aasm_initial_state = Proc.new { |t| (t.show_from && t.user && (t.show_from > t.user.date)) ? :deferred : :active}

  aasm :column => :state do

    state :active
    state :completed, :before_enter => Proc.new { |t| t.completed_at = Time.zone.now }, :before_exit => Proc.new { |t| t.completed_at = nil}
    state :deferred,  :before_exit => Proc.new { |t| t[:show_from] = nil }
    state :pending

    event :defer do
      transitions :to => :deferred, :from => [:active]
    end

    event :complete do
      transitions :to => :completed, :from => [:active, :deferred, :pending]
    end

    event :activate do
      transitions :to => :active, :from => [:deferred]
      transitions :to => :active, :from => [:completed], :guard => :no_uncompleted_predecessors?
      transitions :to => :active, :from => [:pending], :guard => :no_uncompleted_predecessors_or_deferral?
      transitions :to => :pending, :from => [:completed], :guard => :uncompleted_predecessors?
      transitions :to => :deferred, :from => [:pending], :guard => :no_uncompleted_predecessors?
    end

    event :block do
      transitions :to => :pending, :from => [:active, :deferred]
    end
  end

  # Description field can't be empty, and must be < 100 bytes Notes must be <
  # 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => MAX_DESCRIPTION_LENGTH
  validates_length_of :notes, :maximum => MAX_NOTES_LENGTH, :allow_nil => true
  validates_presence_of :show_from, :if => :deferred?
  validates_presence_of :context
  validate :check_show_from_in_future

  def check_show_from_in_future
    if show_from_changed? # only check on change of show_from
      if show_from.present? && (show_from < user.date)
        errors.add("show_from", I18n.t('models.todo.error_date_must_be_future'))
      end
    end
  end

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
    return !uncompleted_predecessors.empty?
  end

  def guard_for_transition_from_deferred_to_pending
    no_uncompleted_predecessors? && not_part_of_hidden_container?
  end

  def not_part_of_hidden_container?
    !( (self.project && self.project.hidden?) || self.context.hidden? )
  end

  # Returns a string with description <context, project>
  def specification
    project_name = self.project.is_a?(NullProject) ? "(none)" : self.project.name
    return "\'#{self.description}\' <\'#{self.context.title}\'; \'#{project_name}\'>"
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

  def touch_predecessors
    self.touch
    predecessors.each(&:touch_predecessors)
  end

  def removed_predecessors
    return @removed_predecessors
  end

  # remove predecessor and activate myself if it was the last predecessor
  def remove_predecessor(predecessor)
    self.predecessors.delete(predecessor)
    if self.predecessors.empty?
      self.reload  # reload predecessors
      self.activate!
    else
      save!
    end
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

  def hidden?
    self.project.hidden? || self.context.hidden?
  end

  def toggle_completion!
    return completed? ? activate! : complete!
  end

  def show_from
    self[:show_from]
  end

  def show_from=(date)
    if deferred? && date.blank?
      activate
    else
      # parse Date objects into the proper timezone
      date = date.in_time_zone.beginning_of_day if (date.is_a? Date)

      # show_from needs to be set before state_change because of "bug" in aasm.
      # If show_from is not set, the todo will not validate and thus aasm will not save
      # (see http://stackoverflow.com/questions/682920/persisting-the-state-column-on-transition-using-rubyist-aasm-acts-as-state-machi)
      self[:show_from] = date

      defer if active? && date.present? && show_from > user.date
    end
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
      predecessor = self.user.todos.find( todo_id.to_i ) if todo_id.present?
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
    pending_todos = successors.select { |t| t.uncompleted_predecessors.empty? and !t.completed? }
    pending_todos.each {|t| t.activate! }
    return pending_todos
  end

  # Return todos that should be blocked if the current todo is undone
  def block_successors
    active_successors = successors.select {|t| t.active? or t.deferred?}
    active_successors.each {|t| t.block!}
    return active_successors
  end

  def raw_notes=(value)
    self[:notes] = value
  end

  # XML API fixups
  def predecessor_dependencies=(params)
    deps = params[:predecessor]
    return if deps.nil?

    # for multiple dependencies, value will be an array of id's, but for a single dependency,
    # value will be a string. In that case convert to array
    deps = [deps] unless deps.class == Array

    deps.each { |dep| self.add_predecessor(self.user.todos.find(dep.to_i)) if dep.present? }
  end

  alias_method :original_context=, :context=
  def context=(value)
    if value.is_a? Context
      self.original_context=(value)
    else
      c = Context.where(:name => value[:name]).first
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
      p = Project.where(:name => value[:name]).first
      p = Project.create(value) if p.nil?
      self.original_project=(p)
    else
      self.original_project=value
    end
  end

  def has_project?
    return ! (project_id.nil? || project.is_a?(NullProject))
  end

  # used by the REST API. <tags> will also work, this is renamed to add_tags in TodosController::TodoCreateParamsHelper::initialize
  def add_tags=(params)
    unless params[:tag].nil?
      tag_list = params[:tag].inject([]) { |list, value| list << value[:name] }
      tag_with tag_list.join(", ")
    end
  end

  def self.import(filename, params, user)
    default_context = user.contexts.order('id').first

    count = 0
    CSV.foreach(filename, headers: true) do |row|
      unless find_by_description_and_user_id row[params[:description].to_i], user.id
        todo = new
        todo.user = user
        todo.description = row[params[:description].to_i].truncate MAX_DESCRIPTION_LENGTH
        todo.context = Context.find_by_name_and_user_id(row[params[:context].to_i], user.id) || default_context
        todo.project = Project.find_by_name_and_user_id(row[params[:project].to_i], user.id) if row[params[:project].to_i].present?
        todo.state = row[params[:completed_at].to_i].present? ? 'completed' : 'active'
        todo.notes = row[params[:notes].to_i].truncate MAX_NOTES_LENGTH if row[params[:notes].to_i].present?
        todo.created_at = row[params[:created_at].to_i] if row[params[:created_at].to_i].present?
        todo.due = row[params[:due].to_i]
        todo.completed_at = row[params[:completed_at].to_i] if row[params[:completed_at].to_i].present?
        todo.save!
        count += 1
      end
    end
    count
  end

  def destroy
    # activate successors if they only depend on this action
    self.pending_successors.each do |successor|
      successor.uncompleted_predecessors.delete(self)
      if successor.uncompleted_predecessors.empty?
        successor.activate!
      end
    end

    super
  end

end
