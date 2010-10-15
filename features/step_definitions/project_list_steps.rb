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

When /^I drag the project "([^"]*)" below "([^"]*)"$/ do |project_drag, project_drop|
  drag_id = @current_user.projects.find_by_name(project_drag).id
  drop_id = @current_user.projects.find_by_name(project_drop).id

  container_height = selenium.get_element_height("//div[@id='container_project_#{drag_id}']").to_i
  vertical_offset = container_height*2
  coord_string = "10,#{vertical_offset}"

  drag_project_handle_xpath = "//div[@id='project_#{drag_id}']//span[@class='handle']"
  drop_project_container_xpath = "//div[@id='container_project_#{drop_id}']"

  selenium.mouse_down_at(drag_project_handle_xpath,"2,2")
  selenium.mouse_move_at(drop_project_container_xpath,coord_string)
  # selenium.mouse_over(drop_project_container_xpath)
  selenium.mouse_up_at(drop_project_container_xpath,coord_string)
end

Then /^the project "([^"]*)" should be above the project "([^"]*)"$/ do |project_high, project_low|
  high_id = @current_user.projects.find_by_name(project_high).id
  low_id = @current_user.projects.find_by_name(project_low).id
  high_pos = selenium.get_element_position_top("//div[@id='project_#{high_id}']").to_i
  low_pos = selenium.get_element_position_top("//div[@id='project_#{low_id}']").to_i
  (high_pos < low_pos).should be_true
end

Then /^the project "([^"]*)" should not be in state list "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  xpath = "//div[@id='list-#{state_name}-projects-container']//div[@id='project_#{project.id}']"
  response.should_not have_xpath(xpath)
end

Then /^the project "([^"]*)" should be in state list "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  xpath = "//div[@id='list-#{state_name}-projects-container']//div[@id='project_#{project.id}']"
  response.should have_xpath(xpath)
end

Then /^the project list badge for "([^"]*)" projects should show (\d+)$/ do |state_name, count|
  selenium.get_text("xpath=//span[@id='#{state_name}-projects-count']").should == count
end

Then /^the new project form should be visible$/ do 
  selenium.is_visible("project_new").should == true
end

Then /^the new project form should not be visible$/ do 
  selenium.is_visible("project_new").should == false
end
