class Context < ActiveRecord::Base

  has_many :todos, :dependent => :delete_all, :order => "completed_at DESC"
  belongs_to :user
  
  acts_as_list :scope => :user
  extend NamePartFinder
  acts_as_todo_container :find_todos_include => :project

  attr_protected :user

  # Context name must not be empty
  # and must be less than 256 characters
  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"
  validates_format_of :name, :with => /^[^\/]*$/i, :message => "cannot contain the slash ('/') character"

  def hidden?
    self.hide == true
  end
  
end
