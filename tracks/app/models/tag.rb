class Tag < ActiveRecord::Base
  has_many_polymorphs :taggables,
                      :from => [:todos], 
                      :through => :taggings,
                      :dependent => :destroy

  def on(taggable, user)
    tagging = taggings.create :taggable => taggable, :user => user
  end

end