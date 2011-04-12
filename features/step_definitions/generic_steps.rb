Given /this is a pending scenario/ do
  pending
end

Given /^I am working on the mobile interface$/ do
  @mobile_interface = true
end

Then /the badge should show (.*)/ do |number|
  badge = -1
  xpath= "//span[@id='badge_count']"

  if response.respond_to? :selenium
    response.should have_xpath(xpath) 
    badge = response.selenium.get_text("xpath=#{xpath}").to_i
  else
    response.should have_xpath(xpath) do |node|
      badge = node.first.content.to_i
    end
  end

  badge.should == number.to_i
end

Then /^I should see the empty message in the deferred container$/ do
  wait_for :timeout => 5 do
    selenium.is_visible("xpath=//div[@id='tickler']//div[@id='tickler-empty-nd']")
  end
end

Then /^I should not see the context "([^"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  wait_for :timeout => 5 do
    !selenium.is_visible("xpath=//div[@id='c#{context.id}']")
  end
end

Then /^I should see an error flash message saying "([^"]*)"$/ do |message|
  xpath = "//div[@id='message_holder']/h4[@id='flash']"
  text = response.selenium.get_text("xpath=#{xpath}")
  text.should == message
end

Then /^I should see "([^"]*)" in context container for "([^"]*)"$/ do |todo_description, context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "xpath=//div[@id=\"c#{context.id}\"]//div[@id='line_todo_#{todo.id}']"
  selenium.wait_for_element(xpath, :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
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

