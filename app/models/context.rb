class Context < ActiveRecord::Base

  has_many :todos, :dependent => :delete_all, :include => :project,
    :order => 'todos.due IS NULL, todos.due ASC, todos.created_at ASC'
  has_many :recurring_todos, :dependent => :delete_all
  belongs_to :user

  scope :active, :conditions => { :hide => false }
  scope :hidden, :conditions => { :hide => true }

  acts_as_list :scope => :user, :top_of_list => 0

  attr_protected :user

  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"

  def self.null_object
    NullContext.new
  end

  def hidden?
    self.hide == true || self.hide == 1
  end

  def title
    name
  end

  def new_record_before_save?
    @new_record_before_save
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