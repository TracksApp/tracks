class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_protected :user

  scope :with_body, lambda { |terms| where("body LIKE ?", terms) }
end
