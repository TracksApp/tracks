require File.dirname(__FILE__) + '/../spec_helper'

describe <%= controller_class_name %>Controller do
  def valid_attributes(args = {})
    {
<% if attributes.empty? -%>
      # Add valid attributes for the your params[:<%= singular_name %>] here!
<% else -%>
  <%- attributes.each_with_index do |attribute, index| -%>
    <%- case attribute.type -%>
      <%- when :string, :text -%>
      "<%= attribute.name %>" => "foo"<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :integer, :float, :decimal -%>
      "<%= attribute.name %>" => 815<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :boolean -%>
      "<%= attribute.name %>" => false<%= index < attributes.size - 1 ? "," : "" %>
      <%- when :date, :datetime, :time, :timestamp -%>
      "<%= attribute.name %>" => 1.week.ago<%= index < attributes.size - 1 ? "," : "" %>
      <%- else -%>
      "<%= attribute.name %>" => nil<%= index < attributes.size - 1 ? "," : "" %> # Could not determine valid attribute
    <%- end -%>
  <%- end -%>
<% end -%>
    }.merge(args)
  end
  
  describe "GET :index" do
    before(:each) do
      @<%= plural_name %> = stub_index(<%= class_name %>)
    end
      
    it_should_find_and_assign :<%= plural_name %>
    it_should_render_template "index"
  end
  
  describe "GET :new" do
    before(:each) do
      @<%= singular_name %> = stub_new(<%= class_name %>)
    end
    
    it_should_initialize_and_assign :<%= singular_name %>
    it_should_render_template "form"
  end
  
  describe "POST :create" do
    describe "when successful" do
      before(:each) do
        @<%= singular_name %> = stub_create(<%= class_name %>)
      end
      
      it_should_initialize_and_save :<%= singular_name %>
      it_should_set_flash :notice
      it_should_redirect_to { <%= singular_name %>_url(@<%= singular_name %>) }
    end
    
    describe "when unsuccessful" do
      before(:each) do
        @<%= singular_name %> = stub_create(<%= class_name %>, :return => :false)
      end
      
      it_should_initialize_and_assign :<%= singular_name %>
      it_should_set_flash :error
      it_should_render_template "form"
    end
  end
  
  describe "GET :show" do
    before(:each) do
      @<%= singular_name %> = stub_show(<%= class_name %>)
    end
    
    it_should_find_and_assign :<%= singular_name %>
    it_should_render_template "show"
  end
  
  describe "GET :edit" do
    before(:each) do
      @<%= singular_name %> = stub_edit(<%= class_name %>)
    end
    
    it_should_find_and_assign :<%= singular_name %>
    it_should_render_template "form"
  end
  
  describe "PUT :update" do
    describe "when successful" do
      before(:each) do
        @<%= singular_name %> = stub_update(<%= class_name %>)
      end
      
      it_should_find_and_update :<%= singular_name %>
      it_should_set_flash :notice
      it_should_redirect_to { <%= singular_name %>_url(@<%= singular_name %>) }
    end
    
    describe "when unsuccessful" do
      before(:each) do
        @<%= singular_name %> = stub_update(<%= class_name %>, :return => :false)
      end
      
      it_should_find_and_assign :<%= singular_name %>
      it_should_set_flash :error
      it_should_render_template "form"
    end
  end
  
  describe "DELETE :destroy" do
    before(:each) do
      @<%= singular_name %> = stub_destroy(<%= class_name %>)
    end
    
    it_should_find_and_destroy :<%= singular_name %>
    it_should_set_flash :notice
    it_should_redirect_to { <%= plural_name %>_url }
  end
end
