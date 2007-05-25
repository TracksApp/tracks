class Tagging < ActiveRecord::Base 
 
  belongs_to :<%= parent_association_name -%><%= ", :foreign_key => \"#{parent_association_name}_id\", :class_name => \"Tag\"" if options[:self_referential] %>
  belongs_to :taggable, :polymorphic => true
  
  # if you want acts_as_list, you will have to manage the tagging positions
  # manually, by created decorated join records
  # acts_as_list :scope => :taggable
    
  def before_destroy
    # if all the taggings for a particular <%= parent_association_name -%> are deleted, we want to 
    # delete the <%= parent_association_name -%> too
    <%= parent_association_name -%>.destroy_without_callbacks if <%= parent_association_name -%>.taggings.count == 1
  end    
end
