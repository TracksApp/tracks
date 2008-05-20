class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :user

  # def before_destroy
  #   # disallow orphaned tags
  #   # TODO: this doesn't seem to be working
  #   tag.destroy if tag.taggings.count < 2  
  # end
end
