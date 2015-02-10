When(/^I collapse the context container of "([^"]*)"$/) do |context_name|
  toggle = page.find(:xpath, toggle_context_container_xpath(find_context(context_name)))
  expect(toggle).to be_visible
  toggle.click
end

When(/^I collapse the project container of "(.*?)"$/) do |project_name|
  toggle = page.find(:xpath, toggle_project_container_xpath(find_project(project_name)))
  expect(toggle).to be_visible
  toggle.click
end

When /^I toggle all collapsed context containers$/ do
  open_view_menu do
    click_link 'Toggle collapsed contexts'
  end
end

####### Context #######

Then(/^I should (see|not see) the context "([^"]*)"$/) do |visible, context_name|
  check_xpath_visibility(visible, context_container_xpath(find_context(context_name)))
end

Then /^I should (see|not see) the container for context "([^"]*)"$/ do |visible, context_name|
  step("I should #{visible} the context \"#{context_name}\"")
end

Then /^I should (see|not see) the context container for "([^"]*)"$/ do |visible, context_name|
  step "I should #{visible} the context \"#{context_name}\""
end

Then(/^the container for the context "([^"]*)" should (be|not be) visible$/) do |context_name, visible|
  mapping = {"be" => "see", "not be" => "not see"}
  step "I should #{mapping[visible]} the context \"#{context_name}\""
end

Then /^I should (see|not see) "([^"]*)" in the context container for "([^"]*)"$/ do |visible, todo_description, context_name|
  check_xpath_visibility(visible, todo_in_context_container_xpath(find_todo(todo_description), find_context(context_name)))
end

Then(/^I should (see|not see) "([^"]*)" in the context container of "([^"]*)"$/) do |visible, todo_description, context_name|
  step "I should #{visible} \"#{todo_description}\" in the context container for \"#{context_name}\""
end

Then /^I should (see|not see) "([^"]*)" in the container for context "([^"]*)"$/ do |visible, todo_description, context_name|
  step "I should #{visible} \"#{todo_description}\" in the context container for \"#{context_name}\""
end

####### Deferred #######

Then(/^I should (not see|see) "([^"]*)" in the deferred container$/) do |visible, todo_description|
  check_xpath_visibility(visible, todo_in_deferred_container_xpath(find_todo(todo_description)))
end

Then(/^I should (not see|see) "([^"]*)" in the action container$/) do |visible, todo_description|
  check_xpath_visibility(visible, todo_in_container_xpath(find_todo(todo_description), @source_view.to_sym))
end

####### Project #######

Then /^I should (see|not see) "([^"]*)" in the project container of "([^"]*)"$/ do |visible, todo_description, project_name|
  check_xpath_visibility(visible, todo_in_project_container_xpath(find_todo(todo_description), find_project(project_name)))
end

Then(/^I should (see|not see) "(.*?)" in the container for project "(.*?)"$/) do |visible, todo_description, project_name|
  step "I should #{visible} \"#{todo_description}\" in the project container of \"#{project_name}\""
end

Then(/^I should (see|not see) "(.*?)" in the project container for "(.*?)"$/) do |visible, todo_description, project_name|
  step "I should #{visible} \"#{todo_description}\" in the project container of \"#{project_name}\""
end

Then(/^I should (see|not see) the project container for "([^"]*)"$/) do |visible, project_name|
  check_xpath_visibility(visible, project_container_xpath(find_project(project_name)))
end

Then(/^I should (see|not see) the container for project "(.*?)"$/) do |visible, project_name|
  step "I should #{visible} the project container for \"#{project_name}\""
end

Then(/^the container for the project "(.*?)" should (be visible|not be visible)$/) do |project_name, visible|
  map = { "be visible" => "see", "not be visible" => "not see"}
  step("I should #{map[visible]} the project container for \"#{project_name}\"")
end

####### Completed #######

Then(/^I should (not see|see) "([^"]*)" in the (completed|done today|done this week|done this month) container$/) do |visible, todo_description, container|
  id = 'completed_container'                if container == 'completed'
  id = 'completed_today_container'          if container == 'done today'
  id = 'completed_rest_of_week_container'   if container == 'done this week'
  id = 'completed_rest_of_month_container'  if container == 'done this month'

  css = "div##{id} div#line_todo_#{find_todo(todo_description).id}"
  check_css_visibility(visible, css)
end

####### Hidden #######

Then /^I should (not see|see) "([^"]*)" in the hidden container$/ do |visible, todo_description|
  xpath = "//div[@id='hidden_container']//div[@id='line_todo_#{find_todo(todo_description).id}']"
  check_xpath_visibility(visible, xpath)
end

####### Calendar #######

Then /^I should see "([^"]*)" in the due next month container$/ do |todo_description|
  within "div#due_after_this_month_container" do
    expect(page).to have_css("div#line_todo_#{find_todo(todo_description).id}")
  end
end

####### Recurrence patterns #######

Then /^I should (see|not see) "([^"]*)" in the active recurring todos container$/ do |visibility, recurrence_pattern|
  recurrence = @current_user.recurring_todos.where(:description => recurrence_pattern).first

  unless recurrence.nil?
    xpath = "//div[@id='active_recurring_todos_container']//div[@id='recurring_todo_#{recurrence.id}']"
    check_xpath_visibility(visibility, xpath)
  else
    step "I should #{visibility} \"#{recurrence_pattern}\""
  end
end

Then /^I should (see|not see) "([^"]*)" in the completed recurring todos container$/ do |visible, recurrence_pattern|
  recurrence = @current_user.todos.where(:description =>  recurrence_pattern).first

  unless recurrence.nil?
    xpath = "//div[@id='completed_recurring_todos_container']//div[@id='recurring_todo_#{recurrence.id}']"
    check_xpath_visibility(visible, xpath)
  else
    step "I should #{visible} \"#{recurrence_pattern}\""
  end
end

####### Empty message patterns #######

Then /^I should (see|not see) empty message for (done today|done this week|done this month|completed todos|deferred todos|todos) (of done actions|of context|of project|of home|of tag)/ do |visible, state, type|
  css = "error: wrong state"
  css = "div#c#{@context.id}-empty-d"             if state == "todos" 
  css = "div#no_todos_in_view"                    if state == "todos" && ["of home", "of tag", "of context", "of project"].include?(type)
  css = "div#completed_today_container"           if state == "done today"
  css = "div#completed_rest_of_week_container"    if state == "done this week"
  css = "div#completed_rest_of_month_container"   if state == "done this month"
  css = "div#completed_container-empty-d"         if state == "completed todos"
  css = "div#deferred_pending_container-empty-d"  if state == "deferred todos"
  
  elem = find(css)
  expect(elem).to_not be_nil

  check_elem_visibility(visible, elem)
end