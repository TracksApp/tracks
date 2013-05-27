class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  scope :with_body, lambda { |terms| where("body LIKE ?", terms) }
end
