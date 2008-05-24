
# The Commenting join model. This model is automatically generated and added to your app if you run the commenting generator.

class Commenting < ActiveRecord::Base 
 
  belongs_to :<%= parent_association_name -%><%= ", :foreign_key => \"#{parent_association_name}_id\", :class_name => \"Comment\"" if options[:self_referential] %>
  belongs_to :commentable, :polymorphic => true
  
  # This callback makes sure that an orphaned <tt>Comment</tt> is deleted if it no longer tags anything.
  def before_destroy
    <%= parent_association_name -%>.destroy_without_callbacks if <%= parent_association_name -%> and <%= parent_association_name -%>.commentings.count == 1
  end    
end
