class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_protected :user

end
