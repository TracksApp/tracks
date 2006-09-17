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

  def not_done_todos
    @not_done_todos = self.find_not_done_todos if @not_done_todos == nil
    @not_done_todos
  end

  def done_todos
    @done_todos = self.find_done_todos if @done_todos == nil
    @done_todos
  end

  def find_not_done_todos
    todos = Todo.find(:all,
                      :conditions => ['todos.context_id = ? and todos.type = ? and todos.done = ?', id, "Immediate", false],
                      :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
                      :include => [ :project, :context ])
                      
  end

  def find_done_todos
    todos = Todo.find :all, :conditions => ["todos.context_id = ? AND todos.type = ? AND todos.done = ?", id, "Immediate", true],
                      :order => "completed DESC",
                      :include => [:context, :project],
                      :limit => @user.preference.show_number_completed
  end

  def hidden?
    self.hide == true
  end

end
