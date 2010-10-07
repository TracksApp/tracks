When /^I delete project "([^"]*)"$/ do |project_name|
  # from the project list page
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  click_link "delete_project_#{project.id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the project '#{project_name}'?"
  wait_for do
    !selenium.is_element_present("delete_project_#{project.id}")
  end
end

Then /^the project list badge for "([^"]*)" projects should show (\d+)$/ do |state_name, count|
  selenium.get_text("css=span##{state_name}-projects-count").should == count
end