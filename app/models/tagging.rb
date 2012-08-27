
# The Tagging join model.

class Tagging < ActiveRecord::Base
  
  attr_accessible :taggable_id, :tag
 
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :touch => true
  
  after_destroy :after_destroy
  
  private
      
  # This callback makes sure that an orphaned <tt>Tag</tt> is deleted if it no longer tags anything.
  def after_destroy
    tag.destroy if tag and tag.taggings.count == 0
  end
  
end
