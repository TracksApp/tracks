require File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../../spec_helper'

describe "<%= File.join(controller_class_path, controller_singular_name) %>/_<%= singular_name %>.html.<%= template_language %>" do
  before(:each) do
    @<%= singular_name %> = mock_and_assign(<%= model_name %>, :stub => {
<% if attributes.blank? -%>
      # Add your stub attributes and return values here like: 
      # :name => "Foo", :created_at => 1.week.ago, :updated_at => nil
<% else -%>
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
<% end -%>
    })
    template.stub!(:<%= singular_name %>).and_return(@<%= singular_name %>)
  end
  
  it_should_link_to_show :<%= singular_name %>
  it_should_link_to_edit :<%= singular_name %>
  it_should_link_to_delete :<%= singular_name %>
end