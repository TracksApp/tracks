class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_protected :user

  def self.list_all
    find(:all, :order => "created_at DESC")
  end

  def self.list_of(project_id)
    find(:all, :conditions => [ "project_id = ?" , project_id ])
  end

end
