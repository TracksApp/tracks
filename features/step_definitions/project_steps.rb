Given /^I have a project "([^\"]*)" with (.*) todos$/ do |project_name, num_todos|
  context = @current_user.contexts.create!(:name => "Context A")
  project = @current_user.projects.create!(:name => project_name)
  1.upto num_todos.to_i do |i|
    @current_user.todos.create!(
      :project_id => project.id,
      :context_id => context.id,
      :description => "Todo #{i}")
  end
end

Given /^there exists a project "([^\"]*)" for user "([^\"]*)"$/ do |project_name, user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil
  user.projects.create!(:name => project_name)
end

When /^I visit the "([^\"]*)" project$/ do |project_name|
  @project = Project.find_by_name(project_name)
  @project.should_not be_nil
  visit project_path(@project)
end

When /^I edit the project description to "([^\"]*)"$/ do |new_description|
  click_link "link_edit_project_#{@project.id}"
  fill_in "project[description]", new_description
  click_button "submit_project_#{@project.id}"
end
