class ActiveRecord::Base
  # These methods will work for any model instances
  
  # Tag with deletes all the current tags before adding the new ones
  # This makes the edit form more intiuitive:
  # Whatever is in the tags text field is what gets set as the tags for that action
  # If you submit an empty tags text field, all the tags are removed.
  def tag_with(tags, user)
    Tag.transaction do
      Tagging.delete_all("taggable_id = #{self.id} and taggable_type = '#{self.class}' and user_id = #{user.id}")
      tags.downcase.split(", ").each do |tag|
        Tag.find_or_create_by_name(tag).on(self, user)
      end
    end
  end

  def tag_list
    tags.map(&:name).join(', ')
  end
  
  def delete_tags tag_string
     split = tag_string.downcase.split(", ")
     tags.delete tags.select{|t| split.include? t.name}
  end

end