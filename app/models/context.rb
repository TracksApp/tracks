class Context < ActiveRecord::Base

  has_many :todos, -> { order("todos.due IS NULL, todos.due ASC, todos.created_at ASC").includes(:project) }, :dependent => :delete_all
  has_many :recurring_todos, :dependent => :delete_all
  belongs_to :user

  scope :active,    -> { where state: :active }
  scope :hidden,    -> { where state: :hidden }
  scope :closed,    -> { where state: :closed }
  scope :with_name, lambda { |name| where("name LIKE ?", name) }

  acts_as_list :scope => :user, :top_of_list => 0

  # state machine
  include AASM

  aasm :column => :state do

    state :active, :initial => true
    state :closed
    state :hidden

    event :close do
      transitions :to => :closed, :from => [:active, :hidden], :guard => :no_active_todos?
    end

    event :hide do
      transitions :to => :hidden, :from => [:active, :closed]
    end

    event :activate do
      transitions :to => :active, :from => [:closed, :hidden]
    end
  end

  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"

  def self.null_object
    NullContext.new
  end

  def title
    name
  end

  def new_record_before_save?
    @new_record_before_save
  end

  def no_active_todos?
    return todos.active.count == 0
  end

end

class NullContext

  def nil?
    true
  end

  def id
    nil
  end

  def name
    ''
  end

end
