class Project < ActiveRecord::Base
  has_many :todos, :dependent => :delete_all
  has_many :notes, :dependent => :delete_all, :order => "created_at DESC"
  has_many :recurring_todos

  belongs_to :default_context, :class_name => "Context", :foreign_key => "default_context_id"
  belongs_to :user

  named_scope :active, :conditions => { :state => 'active' }
  named_scope :hidden, :conditions => { :state => 'hidden' }
  named_scope :completed, :conditions => { :state => 'completed'}
  named_scope :uncompleted, :conditions => ["NOT(state = ?)", 'completed']

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :scope => "user_id"

  acts_as_list :scope => 'user_id = #{user_id} AND state = \'#{state}\'', :top_of_list => 0

  include AASM
  aasm_column :state
  aasm_initial_state :active

  extend NamePartFinder
  #include Tracks::TodoList

  aasm_state :active
  aasm_state :hidden, :enter => :hide_todos, :exit => :unhide_todos
  aasm_state :completed, :enter => :set_completed_at_date, :exit => :clear_completed_at_date

  aasm_event :activate do
    transitions :to => :active,   :from => [:active, :hidden, :completed]
  end

  aasm_event :hide do
    transitions :to => :hidden,   :from => [:active, :completed]
  end

  aasm_event :complete do
    transitions :to => :completed, :from => [:active, :hidden]
  end

  attr_protected :user
  attr_accessor :cached_note_count

  def self.null_object
    NullProject.new
  end

  def self.feed_options(user)
    {
      :title => I18n.t('models.project.feed_title'),
      :description => I18n.t('models.project.feed_description', :username => user.display_name)
    }
  end

  def hide_todos
    todos.each do |t|
      unless t.completed? || t.deferred?
        t.hide!
        t.save
      end
    end
  end

  def unhide_todos
    todos.each do |t|
      if t.project_hidden?
        t.unhide!
        t.save
      end
    end
  end

  def set_completed_at_date
    self.completed_at = Time.zone.now
  end

  def clear_completed_at_date
    self.completed_at = nil
  end

  def note_count
    # TODO: test this for eager and not eager loading!!!
    return 0 if notes.size == 0
    cached_note_count || notes.count
  end

  alias_method :original_default_context, :default_context

  def default_context
    original_default_context.nil? ? Context.null_object : original_default_context
  end

  # would prefer to call this method state=(), but that causes an endless loop
  # as a result of acts_as_state_machine calling state=() to update the attribute
  def transition_to(candidate_state)
    case candidate_state.to_sym
      when aasm_current_state
        return
      when :hidden
        hide!
      when :active
        activate!
      when :completed
        complete!
    end
  end

  def needs_review?(current_user)
    return true if last_reviewed.nil?
    return (active? && (last_reviewed < current_user.time - current_user.prefs.review_period.days)) 
  end

  def blocked?
    ## mutually exclusive for stalled and blocked
    return false if stalled?
    return false if completed?
    is_blocked = true
    todos.each do |t|
      is_blocked = false if (!t.completed? && !t.deferred? && !t.pending?)
    end
    return is_blocked
  end
  
  def stalled?
    return true if todos.count == 0
    return false if completed?
    is_stalled = true
     todos.each do |t|
       is_stalled = false if (!t.completed?)
     end
    return is_stalled
  end


  def name=(value)
    self[:name] = value.gsub(/\s{2,}/, " ").strip
  end

  def new_record_before_save?
    @new_record_before_save
  end

end

class NullProject

  def hidden?
    false
  end

  def nil?
    true
  end

  def id
    nil
  end

end
