class Citation < ActiveRecord::Base
  has_many_polymorphs :items, :from => [:users, :sellers]
end
