require File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../../spec_helper'

describe "<%= File.join(controller_class_path, controller_singular_name) %>/index.html.<%= template_language %>" do
  before(:each) do
    @<%= plural_name %> = mock_and_assign_collection(<%= model_name %>)
    template.stub_render :partial => @<%= plural_name %>
  end
  
  it "should render :partial => @<%= plural_name %>" do
    template.expect_render :partial => @<%= plural_name %>
    do_render
  end
  
  it_should_link_to_new :<%= singular_name %>
end