
# The Tagging join model.

class Tagging < ActiveRecord::Base

  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :touch => true

  after_destroy :delete_orphaned_tag

  private

  def delete_orphaned_tag
    tag.destroy if tag and tag.taggings.count == 0
  end

end
