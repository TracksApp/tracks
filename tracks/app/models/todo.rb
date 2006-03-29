class Todo < ActiveRecord::Base

  belongs_to :context, :order => 'name'
  belongs_to :project
  belongs_to :user
  
  attr_protected :user

  # Description field can't be empty, and must be < 100 bytes
  # Notes must be < 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true 

  def self.not_done( id=id )
    self.find(:all, :conditions =>[ "done = ? AND context_id = ?", false, id], :order =>"due IS NULL, due ASC, created_at ASC")
  end

end
