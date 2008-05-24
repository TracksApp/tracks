
# The Comment model. This model is automatically generated and added to your app if you run the commenting generator.

class Comment < ActiveRecord::Base

  # If database speed becomes an issue, you could remove these validations and rescue the ActiveRecord database constraint errors instead.
  validates_presence_of :name, :email, :body
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  after_validation :prepend_url
  
  # Set up the polymorphic relationship.
  has_many_polymorphs :commentables, 
    :from => [<%= commentable_models.join(", ") %>], 
    :through => :commentings, 
    :dependent => :destroy,
<% if options[:self_referential] -%>    :as => :<%= parent_association_name -%>,
<% end -%>
    :parent_extend => proc {
    }
    
  # Tag::Error class. Raised by ActiveRecord::Base::TaggingExtensions if something goes wrong.
  class Error < StandardError
  end

  protected
  def prepend_url
    return if self[:url].blank?
    if self[:url] !~ /^http(s):\/\//i
      self.url = 'http://' + self[:url]
    end
  end
end
