When /^I collapse the context container of "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.where(:name => context_name).first
  context.should_not be_nil

  xpath = "//a[@id='toggle_c#{context.id}']"
  toggle = page.find(:xpath, xpath)
  toggle.should be_visible
  toggle.click
end

When(/^I collapse the project container of "(.*?)"$/) do |project_name|
  project = @current_user.projects.where(:name => project_name).first
  project.should_not be_nil

  xpath = "//a[@id='toggle_p#{project.id}']"
  toggle = page.find(:xpath, xpath)
  toggle.should be_visible
  toggle.click
end

When /^I toggle all collapsed context containers$/ do
  click_link 'Toggle collapsed contexts'
end

####### Context #######

Then /^I should not see the context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.where(:name => context_name).first
  context.should_not be_nil

  xpath = "//div[@id='c#{context.id}']"
  page.should_not have_xpath(xpath, :visible => true)
end

Then /^I should not see the container for context "([^"]*)"$/ do |context_name|
  step "I should not see the context \"#{context_name}\""
end

Then /^I should not see the context container for "([^"]*)"$/ do |context_name|
  step "I should not see the context \"#{context_name}\""
end

Then /^the container for the context "([^"]*)" should not be visible$/ do |context_name|
  step "I should not see the context \"#{context_name}\""
end

Then /^I should see the container for context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.where(:name => context_name).first
  context.should_not be_nil

  xpath = "//div[@id='c#{context.id}']"
  page.should have_xpath(xpath)
end

Then /^the container for the context "([^"]*)" should be visible$/ do |context_name|
  step "I should see the container for context \"#{context_name}\""
end

Then /^I should (see|not see) "([^"]*)" in the context container for "([^"]*)"$/ do |visible, todo_description, context_name|
  context = @current_user.contexts.where(:name => context_name).first
  context.should_not be_nil
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  xpath = "//div[@id=\"c#{context.id}\"]//div[@id='line_todo_#{todo.id}']"
  page.send( visible=='see' ? :should : :should_not, have_xpath(xpath))
end

####### Deferred #######

Then /^I should see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  page.should have_xpath("//div[@id='deferred_pending_container']//div[@id='line_todo_#{todo.id}']")
end

Then /^I should not see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  page.should_not have_xpath("//div[@id='deferred_pending_container']//div[@id='line_todo_#{todo.id}']")
end

Then /^I should (not see|see) "([^"]*)" in the action container$/ do |visible, todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  id = @source_view=="project" ? "p#{todo.project_id}_items" : "c#{todo.context_id}_items"

  xpath = "//div[@id='#{id}']//div[@id='line_todo_#{todo.id}']"
  page.send(visible=="see" ? :should : :should_not, have_xpath(xpath))
end

Then /^I should not see "([^"]*)" in the context container of "([^"]*)"$/ do |todo_description, context_name|
  step "I should not see \"#{todo_description}\" in the action container"
end

####### Project #######

Then /^I should not see "([^"]*)" in the project container of "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  project = @current_user.projects.where(:name => project_name).first
  project.should_not be_nil

  xpath = "//div[@id='p#{todo.project.id}_items']//div[@id='line_todo_#{todo.id}']"
  page.should_not have_xpath(xpath)
end

Then /^I should see "([^"]*)" in project container for "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  project = @current_user.projects.where(:name => project_name).first
  project.should_not be_nil

  xpath = "//div[@id='p#{project.id}_items']//div[@id='line_todo_#{todo.id}']"
  page.should have_xpath(xpath)
end

Then(/^I should see "(.*?)" in the project container for "(.*?)"$/) do |todo_description, project_name|
  step "I should see \"#{todo_description}\" in project container for \"#{project_name}\""
end

Then /^I should not see the project container for "([^"]*)"$/ do |project_name|
  project = @current_user.projects.where(:name => project_name).first
  project.should_not be_nil

  xpath = "//div[@id='p#{project.id}']"
  page.should_not have_xpath(xpath, :visible => true)
end

####### Completed #######

Then /^I should (not see|see) "([^"]*)" in the (completed|done today|done this week|done this month) container$/ do |visible, todo_description, container|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  id = 'completed_container'                if container == 'completed'
  id = 'completed_today_container'          if container == 'done today'
  id = 'completed_rest_of_week_container'   if container == 'done this week'
  id = 'completed_rest_of_month_container'  if container == 'done this month'

  xpath = "//div[@id='#{id}']//div[@id='line_todo_#{todo.id}']"
  page.send( visible=='see' ? :should : :should_not, have_xpath(xpath))
end

####### Hidden #######

Then /^I should see "([^"]*)" in the hidden container$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  xpath = "//div[@id='hidden_container']//div[@id='line_todo_#{todo.id}']"
  page.should have_xpath(xpath)
end

####### Calendar #######

Then /^I should see "([^"]*)" in the due next month container$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  todo.should_not be_nil

  within "div#due_after_this_month" do
    page.should have_css("div#line_todo_#{todo.id}")
  end
end

####### Repeat patterns #######

Then /^I should (see|not see) "([^"]*)" in the active recurring todos container$/ do |visibility, repeat_pattern|
  repeat = @current_user.recurring_todos.where(:description => repeat_pattern).first

  unless repeat.nil?
    xpath = "//div[@id='active_recurring_todos_container']//div[@id='recurring_todo_#{repeat.id}']"
    page.send(visibility == "see" ? "should" : "should_not", have_xpath(xpath, :visible => true))
  else
    step "I should #{visibility} \"#{repeat_pattern}\""
  end
end

Then /^I should not see "([^"]*)" in the completed recurring todos container$/ do |repeat_pattern|
  repeat = @current_user.todos.where(:description =>  repeat_pattern).first

  unless repeat.nil?
    xpath = "//div[@id='completed_recurring_todos_container']//div[@id='recurring_todo_#{repeat.id}']"
    page.should_not have_xpath(xpath, :visible => true)
  else
    step "I should not see \"#{repeat_pattern}\""
  end
end

####### Empty message patterns #######

Then /^I should (see|not see) empty message for (done today|done this week|done this month|completed todos|deferred todos|todos) (of done actions|of context|of project|of home|of tag)/ do |visible, state, type|
  css = "error: wrong state"
  css = "div#c#{@context.id}-empty-d"             if state == "todos" && type == "of context"
  css = "div#p#{@project.id}-empty-d"             if state == "todos" && type == "of project"
  css = "div#no_todos_in_view"                    if state == "todos" && (type == "of home" || type == "of tag")
  css = "div#completed_today_container"           if state == "done today"
  css = "div#completed_rest_of_week_container"       if state == "done this week"
  css = "div#completed_rest_of_month_container"      if state == "done this month"
  css = "div#completed_container-empty-d"         if state == "completed todos"
  css = "div#deferred_pending_container-empty-d"  if state == "deferred todos"
  
  elem = find(css)
  elem.should_not be_nil
  elem.send(visible=="see" ? :should : :should_not, be_visible)
end