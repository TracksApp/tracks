When /^I collapse the context container of "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil

  xpath = "//a[@id='toggle_c#{context.id}']"
  selenium.is_visible(xpath).should be_true

  selenium.click(xpath)
end

When /^I toggle all collapsed context containers$/ do
  click_link 'Toggle collapsed contexts'
end

####### Context #######

Then /^I should not see the context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil

  xpath = "//div[@id='c#{context.id}']"

  if selenium.is_element_present(xpath) # only check visibility if it is present
    wait_for :timeout => 5 do
      !selenium.is_visible("xpath=#{xpath}")
    end
  end
end

Then /^I should not see the container for context "([^"]*)"$/ do |context_name|
  Then "I should not see the context \"#{context_name}\""
end

Then /^I should not see the context container for "([^"]*)"$/ do |context_name|
  Then "I should not see the context \"#{context_name}\""
end

Then /^the container for the context "([^"]*)" should not be visible$/ do |context_name|
  Then "I should not see the context \"#{context_name}\""
end

Then /^I should see the container for context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil

  xpath = "//div[@id='c#{context.id}']"

  wait_for :timeout => 5 do
    selenium.is_visible(xpath)
  end
end

Then /^the container for the context "([^"]*)" should be visible$/ do |context_name|
  Then "I should see the container for context \"#{context_name}\""
end

Then /^I should see "([^"]*)" in the context container for "([^"]*)"$/ do |todo_description, context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "xpath=//div[@id=\"c#{context.id}\"]//div[@id='line_todo_#{todo.id}']"
  wait_for :timeout => 5 do
    selenium.is_visible(xpath)
  end
end

Then /^I should not see "([^"]*)" in the context container for "([^"]*)"$/ do |todo_description, context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "xpath=//div[@id=\"c#{context.id}\"]//div[@id='line_todo_#{todo.id}']"

  if selenium.is_element_present(xpath)
    # give jquery some time to finish
    wait_for :timeout_in_seconds => 5 do
      !selenium.is_visible(xpath)
    end
  end
end

####### Deferred #######

Then /^I should see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should not see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    !selenium.is_element_present(xpath)
  end
end

####### Project #######

Then /^I should see "([^"]*)" in the action container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='p#{todo.project.id}items']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should not see "([^"]*)" in the project container of "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil

  xpath = "//div[@id='p#{todo.project.id}items']//div[@id='line_todo_#{todo.id}']"

  if selenium.is_element_present(xpath)
    wait_for :timeout => 5 do
        !selenium.is_element_present(xpath)
    end
  end
end

Then /^I should see "([^"]*)" in project container for "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil

  xpath = "//div[@id='p#{project.id}items']//div[@id='line_todo_#{todo.id}']"

  selenium.wait_for_element("xpath=#{xpath}", :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
end

####### Completed #######

Then /^I should see "([^"]*)" in the completed container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='completed_container']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should not see "([^"]*)" in the completed container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='completed_container']//div[@id='line_todo_#{todo.id}']"

  if selenium.is_element_present(xpath)
    wait_for :timeout => 5 do
      !selenium.is_element_present(xpath)
    end
  end
end

####### Hidden #######

Then /^I should see "([^"]*)" in the hidden container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='hidden']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

####### Calendar #######

Then /^I should see "([^"]*)" in the due next month container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  within "div#due_after_this_month" do
    find("div#line_todo_#{todo.id}").should_not be_nil
  end
end

####### Repeat patterns #######

Then /^I should see "([^"]*)" in the active recurring todos container$/ do |repeat_pattern|
  repeat = @current_user.recurring_todos.find_by_description(repeat_pattern)

  unless repeat.nil?
    xpath = "//div[@id='active_recurring_todos_container']//div[@id='recurring_todo_#{repeat.id}']"
    selenium.wait_for_element("xpath=#{xpath}", :timeout_in_seconds => 5)
    selenium.is_visible(xpath).should be_true
  else
    Then "I should not see \"#{repeat_pattern}\""
  end
end

Then /^I should not see "([^"]*)" in the completed recurring todos container$/ do |repeat_pattern|
  repeat = @current_user.recurring_todos.find_by_description(repeat_pattern)

  unless repeat.nil?
    xpath = "//div[@id='completed_recurring_todos_container']//div[@id='recurring_todo_#{repeat.id}']"
    selenium.wait_for_element("xpath=#{xpath}", :timeout_in_seconds => 5)
    selenium.is_visible(xpath).should be_true
  else
    Then "I should not see \"#{repeat_pattern}\""
  end
end

