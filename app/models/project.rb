class Project < ActiveRecord::Base
  has_many :todos, -> {order("todos.due IS NULL, todos.due ASC, todos.created_at ASC")}, dependent: :delete_all
  has_many :notes, -> {order "created_at DESC"}, dependent: :delete_all
  has_many :recurring_todos

  belongs_to :default_context, :class_name => "Context", :foreign_key => "default_context_id"
  belongs_to :user

  scope :active,      -> { where state: 'active' }
  scope :hidden,      -> { where state: 'hidden' }
  scope :completed,   -> { where state: 'completed' }
  scope :uncompleted, -> { where("NOT(state = ?)", 'completed') }

  scope :with_name_or_description, lambda { |body| where("name LIKE ? OR description LIKE ?", body, body) }
  scope :with_namepart, lambda { |body| where("name LIKE ?", body + '%') }

  before_create :set_last_reviewed_now

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :scope => "user_id"

  acts_as_list :scope => 'user_id = #{user_id} AND state = \'#{state}\'', :top_of_list => 0

  include AASM

  aasm :column => :state do

    state :active, :initial => true
    state :hidden, :enter => :hide_todos, :exit => :unhide_todos
    state :completed, :enter => :set_completed_at_date, :exit => :clear_completed_at_date

    event :activate do
      transitions :to => :active,   :from => [:active, :hidden, :completed]
    end

    event :hide do
      transitions :to => :hidden,   :from => [:active, :completed]
    end

    event :complete do
      transitions :to => :completed, :from => [:active, :hidden]
    end
  end

  attr_accessor :cached_note_count

  def self.null_object
    NullProject.new
  end

  def set_last_reviewed_now
    self.last_reviewed = Time.now
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
      when aasm.current_state
        return
      when :hidden
        hide!
      when :active
        activate!
      when :completed
        complete!
    end
  end

  def needs_review?(user)
    return active? && ( last_reviewed.nil? ||
                        (last_reviewed < Time.current - user.prefs.review_period.days))
  end

  def blocked?
    ## mutually exclusive for stalled and blocked
    # blocked is uncompleted project with deferred or pending todos, but no next actions
    return false if self.completed?
    return !self.todos.deferred_or_blocked.empty? && self.todos.active.empty?
  end

  def stalled?
    # Stalled projects are active projects with no active next actions
    return false if self.completed? || self.hidden?
    return self.todos.deferred_or_blocked.empty? && self.todos.active.empty?
  end

  def shortened_name(length=40)
    name.truncate(length, :omission => "...").html_safe
  end

  def name=(value)
    if value
      self[:name] = value.gsub(/\s{2,}/, " ").strip
    else
      self[:name] = nil
    end
  end

  def new_record_before_save?
    @new_record_before_save
  end

  def age_in_days
    @age_in_days ||= (Time.current.to_date - created_at.to_date).to_i + 1
  end

  def running_time
    if completed_at.nil?
      return age_in_days
    else
      return (completed_at.to_date - created_at.to_date).to_i + 1
    end
  end

  def self.import(filename, params, user)
    count = 0
    CSV.foreach(filename, headers: true) do |row|
      unless find_by_name_and_user_id row[params[:name].to_i], user.id
        project = new
        project.name = row[params[:name].to_i]
        project.user = user
        project.description = row[params[:description].to_i] if row[params[:description].to_i].present?
        project.state = 'active'
        project.save!
        count += 1
      end
    end
    count
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

  def name
    ""
  end

  def persisted?
    false
  end

end
