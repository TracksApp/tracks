
# The Tagging join model. This model is automatically generated and added to your app if you run the tagging generator included with has_many_polymorphs.

class Tagging < ActiveRecord::Base
 
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
      
  # This callback makes sure that an orphaned <tt>Tag</tt> is deleted if it no longer tags anything.
  def after_destroy
    tag.destroy_without_callbacks if tag and tag.taggings.count == 0
  end
end
