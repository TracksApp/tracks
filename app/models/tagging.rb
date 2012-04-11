
# The Tagging join model.

class Tagging < ActiveRecord::Base
 
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
      
  # This callback makes sure that an orphaned <tt>Tag</tt> is deleted if it no longer tags anything.
  def after_destroy
    tag.destroy_without_callbacks if tag and tag.taggings.count == 0
  end
end
