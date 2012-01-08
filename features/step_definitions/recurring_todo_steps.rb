Given /^I have a repeat pattern called "([^"]*)"$/ do |pattern_name|
  context = @current_user.contexts.first

  @recurring_todo = @current_user.recurring_todos.create!(
    :description => pattern_name,
    :context_id => context.id,
    :state => 'active',
    :start_from => Time.now - 1.day,
    :ends_on => 'no_end_date',
    :target => 'due_date',
    :recurring_period => 'daily',
    :every_other1 => 1,
    :show_always => 1,
    :created_at => Time.now - 1.day,
    :completed_at => nil
  )
  @recurring_todo.completed?.should be_false
  @todo = @current_user.todos.create!(
    :description => pattern_name,
    :context_id => context.id,
    :recurring_todo_id => @recurring_todo.id)
end

Given /^I have a completed repeat pattern "([^"]*)"$/ do |pattern_name|
  Given "I have a repeat pattern called \"#{pattern_name}\""
  @recurring_todo.toggle_completion!
  @recurring_todo.completed?.should be_true
end

Given /^I have (\d+) completed repeat patterns$/ do |number_of_patterns|
  1.upto number_of_patterns.to_i do |i|
    Given "I have a completed repeat pattern \"Repeating Todo #{i}\""
  end
end

When /^I select "([^\"]*)" recurrence pattern$/ do |recurrence_period|
  selenium.click("recurring_todo_recurring_period_#{recurrence_period.downcase}")
end

When /^I edit the name of the pattern "([^\"]*)" to "([^\"]*)"$/ do |pattern_name, new_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  click_link "link_edit_recurring_todo_#{pattern.id}"

  wait_for_ajax

  fill_in "edit_recurring_todo_description", :with => new_name
  selenium.click "recurring_todo_edit_update_button"

  wait_for do
    !selenium.is_visible("edit-recurring-todo")
  end
end

When /^I star the pattern "([^\"]*)"$/ do |pattern_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  click_link "star_icon_#{pattern.id}"
  wait_for_ajax
end

When /^I delete the pattern "([^"]*)"$/ do |pattern_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  click_link "delete_icon_#{pattern.id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the recurring action '#{pattern_name}'?"
  wait_for do
    !selenium.is_element_present("delete_icon_#{pattern.id}")
  end
end

When /^I mark the pattern "([^"]*)" as complete$/ do |pattern_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  pattern.completed?.should be_false
  selenium.click "check_#{pattern.id}"
  wait_for_ajax
end

When /^I mark the pattern "([^"]*)" as active$/ do |pattern_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  pattern.completed?.should be_true
  selenium.click "check_#{pattern.id}"
  wait_for_ajax
end

When /^I follow the recurring todo link of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  recurring_todo_link = "xpath=//div[@id='todo_#{todo.id}']//a[@class='recurring_icon']/img"
  selenium.click( recurring_todo_link )
  selenium.wait_for_page_to_load(5000)
end

Then /^the state list "([^"]*)" should be empty$/ do |state|
  empty_id = "recurring-todos-empty-nd" if state.downcase == "active"
  empty_id = "completed-empty-nd" if state.downcase == "completed"
  selenium.is_visible( empty_id )
end

Then /^the pattern "([^\"]*)" should be starred$/ do |pattern_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  xpath = "//div[@id='recurring_todo_#{pattern.id}']//img[@class='todo_star starred']"
  response.should have_xpath(xpath)
end

Then /^I should see the form for "([^\"]*)" recurrence pattern$/ do |recurrence_period|
  selenium.is_visible("recurring_#{recurrence_period.downcase}")
end

Then /^the pattern "([^"]*)" should be in the state list "([^"]*)"$/ do |pattern_name, state_name|
  pattern = @current_user.recurring_todos.find_by_description(pattern_name)
  pattern.should_not be_nil
  xpath = "//div[@id='#{state_name}_recurring_todos_container']//div[@id='recurring_todo_#{pattern.id}']"
  response.should have_xpath(xpath)
end
