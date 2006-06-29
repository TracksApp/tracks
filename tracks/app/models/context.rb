class Context < ActiveRecord::Base

  has_many :todos, :dependent => true, :order => "completed DESC"
  belongs_to :user
  acts_as_list :scope => :user

  attr_protected :user

  # Context name must not be empty
  # and must be less than 256 characters
  validates_presence_of :name, :message => "context must have a name"
  validates_length_of :name, :maximum => 255, :message => "context name must be less than 256 characters"
  validates_uniqueness_of :name, :message => "already exists", :scope => "user_id"
  validates_format_of :name, :with => /^[^\/]*$/i, :message => "cannot contain the slash ('/') character"

  def self.list_of(hidden=false)
    find(:all, :conditions => [ "hide = ?" , hidden ], :order => "position ASC")
  end

  def find_not_done_todos
    todos = Todo.find :all, :conditions => ["todos.context_id = #{id} AND todos.done = ? AND type = ?", false, "Immediate"],
                      :include => [:context, :project],
                      :order => "due IS NULL, due ASC, created_at ASC"
  end

  def find_done_todos
    todos = Todo.find :all, :conditions => ["todos.context_id = #{id} AND todos.done = ? AND type = ?", true, "Immediate"],
                      :include => [:context, :project],
                      :order => "completed DESC",
                      :limit => @user.preferences["no_completed"].to_i
  end

  # Returns a count of next actions in the given context
  # The result is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos(string="actions")
    count = self.find_not_done_todos.size
    if count == 1
      word = string.singularize
    else
      word = string.pluralize
    end
    return count.to_s + " " + word
  end

  def hidden?
    self.hide == true
  end

end
