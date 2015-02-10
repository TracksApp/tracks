class RecurringTodo < ActiveRecord::Base
  belongs_to :context
  belongs_to :project
  belongs_to :user

  has_many :todos

  scope :active,    -> { where state: 'active'}
  scope :completed, -> { where state: 'completed'}

  include IsTaggable

  include AASM
  aasm :column => :state do
    state :active, :initial => true, :before_enter => Proc.new { |t| t.occurrences_count = 0 }
    state :completed, :before_enter => Proc.new { |t| t.completed_at = Time.zone.now }, :before_exit => Proc.new { |t| t.completed_at = nil }

    event :complete do
      transitions :to => :completed, :from => [:active]
    end

    event :activate do
      transitions :to => :active, :from => [:completed]
    end
  end

  validates_presence_of :description, :recurring_period, :target, :ends_on, :context

  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true

  validate :period_validation
  validate :pattern_specific_validations

  def pattern_specific_validations
    if pattern
      pattern.validate
    else
      errors[:recurring_todo] << "Invalid recurrence period '#{recurring_period}'"
    end
  end

  def valid_period?
    %W[daily weekly monthly yearly].include?(recurring_period)
  end

  def period_validation
    errors.add(:recurring_period, "is an unknown recurrence pattern: '#{recurring_period}'") unless valid_period?
  end

  # the following recurrence patterns can be stored:
  #
  # daily todos - recurrence_period = 'daily'
  #   every nth day - nth stored in every_other1
  #   every work day - only_work_days = true
  #   tracks will choose between both options using only_work_days
  # weekly todos - recurrence_period = 'weekly'
  #   every nth week on a specific day -
  #      nth stored in every_other1 and the specific day is stored in every_day
  # monthly todos - recurrence_period = 'monthly'
  #   every day x of nth month - x stored in every_other1 and nth is stored in every_other2
  #   the xth y-day of every nth month (the forth tuesday of every 2 months) -
  #      x stored in every_other3, y stored in every_count, nth stored in every_other2
  #   choosing between both options is done on recurrence_selector where 0 is
  #   for first type and 1 for second type
  # yearly todos - recurrence_period = 'yearly'
  #   every day x of month y - x is stored in every_other1, y is stored in every_other2
  #   the x-th day y of month z (the forth tuesday of september) -
  #     x is stored in every_other3, y is stored in every_count, z is stored in every_other2
  #   choosing between both options is done on recurrence_selector where 0 is
  #   for first type and 1 for second type

  def pattern
    if valid_period?
      @pattern = eval("RecurringTodos::#{recurring_period.capitalize}RecurrencePattern.new(user)")
      @pattern.build_from_recurring_todo(self)
    end
    @pattern
  end

  def recurrence_pattern
    pattern.recurrence_pattern
  end

  def recurring_target_as_text
    pattern.recurring_target_as_text
  end

  def starred?
    has_tag?(Todo::STARRED_TAG_NAME)
  end

  def get_due_date(previous)
    pattern.get_due_date(previous)
  end

  def get_show_from_date(previous)
    pattern.get_show_from_date(previous)
  end

  def done?(end_date)
    !continues_recurring?(end_date)
  end

  def toggle_completion!
    completed? ? activate! : complete!
  end

  def toggle_star!
    if starred?
      _remove_tags(Todo::STARRED_TAG_NAME)
    else
      _add_tags(Todo::STARRED_TAG_NAME)
    end
    tags.reload
    starred?
  end

  def remove_from_project!
    self.project = nil
    self.save
  end

  def clear_todos_association
    unless todos.nil?
      self.todos.each do |t|
        t.recurring_todo = nil
        t.save
      end
    end
  end

  def increment_occurrences
    self.occurrences_count += 1
    self.save
  end

  def continues_recurring?(previous)
    pattern.continues_recurring?(previous)
  end

end
