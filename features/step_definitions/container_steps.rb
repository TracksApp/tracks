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

Then /^the container for the context "([^"]*)" should not be visible$/ do |context_name|
  Then "I should not see the context \"#{context_name}\""
end

Then /^I should see the container for context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil

  xpath = "xpath=//div[@id='c#{context.id}']"

  selenium.wait_for_element(xpath, :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
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
  selenium.wait_for_element(xpath, :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
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


Then /^I should see "([^"]*)" in project container for "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil

  xpath = "//div[@id='p#{project.id}items']//div[@id='line_todo_#{todo.id}']"

  selenium.wait_for_element("xpath=#{xpath}", :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
end