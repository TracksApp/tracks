require File.dirname(__FILE__) + '/../../spec_helper'

describe "/notes/_notes.rhtml" do
  before :each do
    @project = mock_model(Project, :name => "a project")
    @note = mock_model(Note, :body => "this is a note", :project => @project, 
      :created_at => Time.now, :updated_at? => false)
    @controller.template.stub!(:apply_behavior)
    @controller.template.stub!(:format_date)
    @controller.template.stub!(:render)
    @controller.template.stub!(:form_remote_tag)
  end
  
  it "should render" do
    render :partial => "/notes/notes", :locals => {:notes => @note}
    response.should have_tag("div.note_footer")
  end
  
  it "should auto-link URLs" do
    @note.stub!(:body).and_return("http://www.google.com/")
    render :partial => "/notes/notes", :locals => {:notes => @note}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
  
  it "should auto-link embedded URLs" do
    @note.stub!(:body).and_return("this is cool: http://www.google.com/")
    render :partial => "/notes/notes", :locals => {:notes => @note}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
  
  it "should parse Textile links correctly" do
    @note.stub!(:body).and_return("\"link\":http://www.google.com/")
    render :partial => "/notes/notes", :locals => {:notes => @note}
    response.should have_tag("a[href=\"http://www.google.com/\"]")
  end
end
