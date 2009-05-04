require File.dirname(__FILE__) + '/../../spec_helper'

describe "/todos/_toggle_notes.rhtml" do
  # include ControllerHelper
  
  before :each do
    @item = mock_model(Todo, :notes => "this is a note")
    @controller.template.stub!(:apply_behavior)
    @controller.template.stub!(:set_default_external!)
  end
  
  it "should render" do
    render :partial => "/todos/toggle_notes", :locals => {:item => @item}
    response.should have_tag("div.todo_notes")
  end
  
  it "should auto-link URLs" do
    @item.stub!(:notes).and_return("http://www.google.com/")
    render :partial => "/todos/toggle_notes", :locals => {:item => @item}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
  
  it "should auto-link embedded URLs" do
    @item.stub!(:notes).and_return("this is cool: http://www.google.com/")
    render :partial => "/todos/toggle_notes", :locals => {:item => @item}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
  
  it "should parse Textile URLs correctly" do
    @item.stub!(:notes).and_return("\"link\":http://www.google.com/")
    render :partial => "/todos/toggle_notes", :locals => {:item => @item}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
end
