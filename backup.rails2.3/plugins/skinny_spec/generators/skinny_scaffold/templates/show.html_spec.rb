require File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../../spec_helper'

describe "<%= File.join(controller_class_path, controller_singular_name) %>/show.html.<%= template_language %>" do
  before(:each) do
<% if attributes.blank? -%>
    @<%= singular_name %> = mock_and_assign(<%= model_name %>)
<% else -%>
    @<%= singular_name %> = mock_and_assign(<%= model_name %>, :stub => {
  <%- attributes.each_with_index do |attribute, index| -%>
    <%- case attribute.type when :string, :text -%>
      :<%= attribute.name %> => "foo"<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :integer, :float, :decimal -%>
      :<%= attribute.name %> => 815<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :boolean -%>
      :<%= attribute.name %> => false<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :date, :datetime, :time, :timestamp -%>
      :<%= attribute.name %> => 1.week.ago<%= index < attributes.size - 1 ? "," : "" %>
      <%- else -%>
      :<%= attribute.name %> => nil<%= index < attributes.size - 1 ? "," : "" %>
    <%- end -%>
  <%- end -%>
    })
<% end -%>
  end
  
  # Add your specs here, please! But remember not to make them brittle
  # by specing specing specific HTML elements and classes.
  
  it_should_link_to_edit :<%= singular_name %>
  it_should_link_to { <%= plural_name %>_path }
end