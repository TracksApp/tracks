Given /^I have a project "([^"]*)" with (\d+) active todos$/ do |name, count|
  @context = @current_user.contexts.find_or_create_by_name("Context A")
  @project = @current_user.projects.find_or_create_by_name(name)

  @todos=[]
  1.upto count.to_i do |i|
    todo = @current_user.todos.create!(
      :project_id => @project.id,
      :context_id => @context.id,
      :description => "todo #{i}")
    @todos << todo
  end
end

Given /^I have a project "([^"]*)" with (\d+) deferred actions$/ do |name, deferred|
  step "I have a project \"#{name}\" with #{deferred} active todos"
  @todos.each do |t|
    t.show_from = Time.zone.now + 1.week
    t.description = "deferred " + t.description
    t.save!
  end
end

Given /^I have a project "([^"]*)" with (\d+) active actions and (\d+) deferred actions$/ do |name, active_count, deferred_count|
  step "I have a project \"#{name}\" with #{active_count} active todos"
  step "I have a project \"#{name}\" with #{deferred_count} deferred actions"
end

When /^I delete project "([^"]*)"$/ do |project_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  
  handle_js_confirm do
    click_link "delete_project_#{project.id}"
  end
  get_confirm_text.should == "Are you sure that you want to delete the project '#{project_name}'?"
  
  wait_until do
    !page.has_css?("a#delete_project_#{project.id}")
  end
end

When /^I drag the project "([^"]*)" below "([^"]*)"$/ do |project_drag, project_drop|
  drag_id = @current_user.projects.find_by_name(project_drag).id
  sortable_css = "div.ui-sortable div#container_project_#{drag_id}"

  drag_index = project_list_find_index(project_drag)
  drop_index = project_list_find_index(project_drop)
  
  page.execute_script "$('#{sortable_css}').simulateDragSortable({move: #{drop_index-drag_index}, handle: '.grip'});"
end

When /^I submit a new project with name "([^"]*)"$/ do |project_name|
  fill_in "project[name]", :with => project_name
  submit_new_project_form
end

When /^I submit a new project with name "([^"]*)" and select take me to the project$/ do |project_name|
  fill_in "project[name]", :with => project_name
  check "go_to_project"
  submit_new_project_form
end

When /^I sort the active list alphabetically$/ do
  handle_js_confirm do
    click_link "Alphabetically"
    wait_for_ajax
  end
  get_confirm_text.should == "Are you sure that you want to sort these projects alphabetically? This will replace the existing sort order."
end

When /^I sort the list by number of tasks$/ do
  handle_js_confirm do
    click_link "By number of tasks"
    wait_for_ajax
  end
  get_confirm_text.should == "Are you sure that you want to sort these projects by the number of tasks? This will replace the existing sort order."
end

Then /^I should see that a project named "([^"]*)" is not present$/ do |project_name|
  within "div#display_box" do
    step "I should not see \"#{project_name}\""
  end
end

Then /^I should see that a project named "([^"]*)" is present$/ do |project_name|
  within "div#display_box" do
    step "I should see \"#{project_name}\""
  end
end

Then /^I should see a project named "([^"]*)"$/ do |project_name|
  step "I should see that a project named \"#{project_name}\" is present"
end

Then /^I should not see a project named "([^"]*)"$/ do |project_name|
  step "I should see that a project named \"#{project_name}\" is not present"
end

Then /^the project "([^"]*)" should be above the project "([^"]*)"$/ do |project_high, project_low|
  project_list_find_index(project_high).should < project_list_find_index(project_low)
end

Then /^the project "([^"]*)" should not be in state list "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  xpath = "//div[@id='list-#{state_name}-projects-container']//div[@id='project_#{project.id}']"
  page.has_xpath?(xpath).should_not be_true
end

Then /^the project "([^"]*)" should be in state list "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil
  xpath = "//div[@id='list-#{state_name}-projects-container']//div[@id='project_#{project.id}']"
  page.has_xpath?(xpath).should be_true
end

Then /^the project list badge for "([^"]*)" projects should show (\d+)$/ do |state_name, count|
  page.find(:xpath, "//span[@id='#{state_name}-projects-count']").text.should == count
end

Then /^the new project form should be visible$/ do
  page.has_css?("div#project_new", :visible => true).should be_true
end

Then /^the new project form should not be visible$/ do
  page.has_css?("div#project_new", :visible => true).should be_false
end

Then /^the project "([^"]*)" should have (\d+) actions listed$/ do |name, count|
  project = @current_user.projects.find_by_name(name)
  project.should_not be_nil
  xpath = "//div[@id='list-active-projects-container']//div[@id='project_#{project.id}']//span[@class='needsreview']"
  page.find(:xpath, xpath).text.should == "#{project.name} (#{count} actions)"
end

Then /^the project "([^"]*)" should have (\d+) deferred actions listed$/ do |name, deferred|
  project = @current_user.projects.find_by_name(name)
  project.should_not be_nil
  xpath = "//div[@id='list-active-projects-container']//div[@id='project_#{project.id}']//span[@class='needsreview']"
  page.find(:xpath, xpath).text.should == "#{project.name} (#{deferred} deferred actions)"
end