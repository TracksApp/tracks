class Context < ActiveRecord::Base

  has_many :todos, :dependent => :delete_all, :include => :project, :order => "completed_at DESC"
  belongs_to :user
  
  acts_as_list :scope => :user
  extend NamePartFinder
  include Tracks::TodoList
  include UrlFriendlyName

  attr_protected :user

  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"
  validates_does_not_contain :name, :string => '/', :message => "cannot contain the slash ('/') character"
  validates_does_not_contain :name, :string => ',', :message => "cannot contain the comma (',') character"

  def hidden?
    self.hide == true
  end
    
end
