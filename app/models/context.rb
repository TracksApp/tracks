class Context < ActiveRecord::Base

  has_many :todos, :dependent => :delete_all, :include => :project, :order => "todos.completed_at DESC"
  has_many :recurring_todos, :dependent => :delete_all
  belongs_to :user

  named_scope :active, :conditions => { :hide => false }
  named_scope :hidden, :conditions => { :hide => true }

  acts_as_list :scope => :user, :top_of_list => 0
  extend NamePartFinder
  include Tracks::TodoList

  attr_protected :user

  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"
  validates_does_not_contain :name, :string => ',', :message => "cannot contain the comma (',') character"

  def self.feed_options(user)
    # TODO: move to view or helper
    {
      :title => 'Tracks Contexts',
      :description => "Lists all the contexts for #{user.display_name}"
    }
  end

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