class Project < ActiveRecord::Base
  has_many :todos, :dependent => :delete_all, :include => :context
  has_many :notes, :dependent => :delete_all, :order => "created_at DESC"
  belongs_to :user
  
  validates_presence_of :name, :message => "project must have a name"
  validates_length_of :name, :maximum => 255, :message => "project name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope =>"user_id"
  validates_does_not_contain :name, :string => '/', :message => "cannot contain the slash ('/') character"
  validates_does_not_contain :name, :string => ',', :message => "cannot contain the comma (',') character"

  acts_as_list :scope => 'user_id = #{user_id} AND state = \'#{state}\''
  acts_as_state_machine :initial => :active, :column => 'state'
  extend NamePartFinder
  include Tracks::TodoList
  include UrlFriendlyName
  
  state :active
  state :hidden, :enter => :hide_todos, :exit => :unhide_todos
  state :completed

  event :activate do
    transitions :to => :active,   :from => [:hidden, :completed]
  end
  
  event :hide do
    transitions :to => :hidden,   :from => [:active, :completed]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :hidden]
  end
  
  attr_protected :user

  def self.null_object
    NullProject.new
  end
  
  def self.feed_options(user)
    {
      :title => 'Tracks Projects',
      :description => "Lists all the projects for #{user.display_name}"
    }
  end
  
  def to_param
    url_friendly_name
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

  # would prefer to call this method state=(), but that causes an endless loop
  # as a result of acts_as_state_machine calling state=() to update the attribute
  def transition_to(candidate_state)
    case candidate_state.to_sym
      when current_state
        return
      when :hidden
        hide!
      when :active
        activate!
      when :completed
        complete!
    end
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