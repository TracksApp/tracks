require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  it "should save default tags" do
    project = Project.new

    projects = mock(:project_list, :build => project,
      :active => mock(:meh, :count => 0), :size => 0)

    user = mock_model(User, :projects => projects, :prefs => {},
      :contexts => mock(:context_list, :find => []))
    controller.stub!(:current_user).and_return(user)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:set_time_zone).and_return(true)
    controller.stub!(:mobile?).and_return(true)

    get 'create', :project => {:name => "fooproject", :default_tags => "a,b"}

    project.default_tags.should == 'a,b'
  end
end
