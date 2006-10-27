class Project < ActiveRecord::Base
  has_many :todos, :dependent => true
  has_many :notes, :dependent => true, :order => "created_at DESC"
  belongs_to :user
  
  # Project name must not be empty
  # and must be less than 255 bytes
  validates_presence_of :name, :message => "project must have a name"
  validates_length_of :name, :maximum => 255, :message => "project name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope =>"user_id"
  validates_format_of :name, :with => /^[^\/]*$/i, :message => "cannot contain the slash ('/') character"

  acts_as_list :scope => :user
  acts_as_state_machine :initial => :active, :column => 'state'
  acts_as_namepart_finder
  acts_as_todo_container :find_todos_include => :context
  
  state :active
  state :hidden
  state :completed

  event :activate do
    transitions :to => :active,   :from => [:hidden, :complete]
  end
  
  event :hide do
    transitions :to => :hidden,   :from => [:active, :complete]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :hidden]
  end
  
  attr_protected :user

  def description_present?
    attribute_present?("description")
  end
  
  def linkurl_present?
    attribute_present?("linkurl")
  end
      
end
