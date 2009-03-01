require File.dirname(__FILE__) + '/../spec_helper'

describe TodosController do
  it "should add project's default tags to todos" do
    p = mock_model(Project, :new_record_before_save? => false)
    p.should_receive(:default_tags).twice.and_return('abcd,efgh')
    todo = mock_model(Todo, :save => true, :update_state_from_project => nil,
      :tags => mock(:tag_list, :reload => nil))
    todo.stub!(:project_id=)
    todo.should_receive(:tag_with).with('abcd,efgh')
    projects = mock(:project_list, :find_or_create_by_name => p, :find => [p])
    todos = mock(:todo_list, :build => todo)

    user = mock_model(User, :todos => todos, :projects => projects, :prefs => {},
      :contexts => mock(:context_list, :find => []))
    controller.stub!(:current_user).and_return(user)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:set_time_zone).and_return(true)
    controller.stub!(:mobile?).and_return(true)
    get 'create', :project_name => "zzzz", :tag_list => '', :todo => {}
  end

  it "should append project's default tags to todos" do
    p = mock_model(Project, :new_record_before_save? => false)
    p.should_receive(:default_tags).twice.and_return('abcd,efgh')
    todo = mock_model(Todo, :save => true, :update_state_from_project => nil,
      :tags => mock(:tag_list, :reload => nil))
    todo.stub!(:project_id=)
    todo.should_receive(:tag_with).with('111,222,abcd,efgh')
    projects = mock(:project_list, :find_or_create_by_name => p, :find => [p])
    todos = mock(:todo_list, :build => todo)

    user = mock_model(User, :todos => todos, :projects => projects, :prefs => {},
      :contexts => mock(:context_list, :find => []))
    controller.stub!(:current_user).and_return(user)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:set_time_zone).and_return(true)
    controller.stub!(:mobile?).and_return(true)
    get 'create', :project_name => "zzzz", :tag_list => '111,222', :todo => {}
  end
end
