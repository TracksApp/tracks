require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper'

describe <%= class_name %> do
  def valid_attributes(args = {})
    {
      # Add valid attributes for building your model instances here!
    }.merge(args)
  end
  
  before(:each) do
    @<%= singular_name %> = <%= class_name %>.new
  end
  
  after(:each) do
    @<%= singular_name %>.destroy
  end
  
  # Add your model specs here, please!
  # And don't forget about the association matchers built-in to skinny_spec like:
  # 
  #   it_should_have_many :foos
  #   it_should_validate_presence_of :bar
  # 
  # Check out the docs for more information.
end