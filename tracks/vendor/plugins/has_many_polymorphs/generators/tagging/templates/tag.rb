class Tag < ActiveRecord::Base

  DELIMITER = " " # how to separate tags in strings (you may
    # also need to change the validates_format_of parameters 
    # if you update this)

  # if speed becomes an issue, you could remove these validations 
  # and rescue the AR index errors instead
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :name, :with => /^[a-zA-Z0-9\_\-]+$/, 
    :message => "can not contain special characters"
    
  has_many_polymorphs :taggables, 
    :from => [<%= taggable_models.join(", ") %>], 
    :through => :taggings, 
    :dependent => :destroy,
<% if options[:self_referential] -%>    :as => :<%= parent_association_name -%>,
<% end -%>
    :skip_duplicates => false, 
    :parent_extend => proc { # XXX this isn't right
      def to_s
        self.map(&:name).sort.join(Tag::DELIMITER)
      end
    }
    
  def before_create 
    # if you allow editable tag names, you might want before_save instead 
    self.name = name.downcase.strip.squeeze(" ")
  end
  
  class Error < StandardError
  end
    
end
