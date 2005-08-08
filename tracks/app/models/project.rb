class Project < ActiveRecord::Base

  has_many :todos, :dependent => true
  has_many :notes, :order => "created_at DESC"
  belongs_to :user
  acts_as_list :scope => :user

  attr_protected :user

  # Project name must not be empty
  # and must be less than 255 bytes
  validates_presence_of :name, :message => "project must have a name"
  validates_length_of :name, :maximum => 255, :message => "project name must be less than %d"
  validates_uniqueness_of :name, :message => "already exists", :scope =>"user_id"

  def self.list_of(isdone=0)
    find(:all, :conditions => [ "done = ?" , isdone ], :order => "position ASC")
  end

  def find_not_done_todos
    todos = Todo.find :all, :conditions => "project_id = #{id} AND done = 0",
                      :order => "due IS NULL, due ASC, created_at ASC"
  end

  def find_done_todos
    todos = Todo.find :all, :conditions => "project_id = #{id} AND done = 1",
                      :order => "due IS NULL, due ASC, created_at ASC"
  end

  # Returns a count of next actions in the given project
  # The result is count and a string descriptor, correctly pluralised if there are no
  # actions or multiple actions
  #
  def count_undone_todos(string="actions")
    count = find_not_done_todos.size
    if count == 1
      word = string.singularize
    else
      word = string.pluralize
    end
    return count.to_s + " " + word
  end

end
