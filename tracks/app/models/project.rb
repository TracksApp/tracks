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
      :description => "Lists all the projects for #{user.display_name}."
    }
  end
  
  def to_param
    url_friendly_name
  end
  
  def description_present?
    attribute_present?("description")
  end
  
  def linkurl_present?
    attribute_present?("linkurl")
  end
  
  def title
    name
  end
    
  def summary(undone_todo_count)
    project_description = ''
    project_description += sanitize(markdown( description )) if description_present?
	 	project_description += "<p>#{undone_todo_count}. "
	 	project_description += "Project is #{state}. "
	 	project_description += "<a href=\"#{linkurl}\">#{linkurl}</a>" if linkurl_present?
	 	project_description += "</p>"
	 	project_description
  end
    
  def hide_todos
    todos.each do |t|
      t.hide! unless t.completed? || t.deferred?
      t.save
    end
  end
      
  def unhide_todos
    todos.each do |t|
      t.unhide! if t.project_hidden?
      t.save
    end
  end
  
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