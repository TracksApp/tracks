Given /^I have no todos$/ do
  Todo.delete_all
end

Given /^I have a todo "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  context = @current_user.contexts.find_or_create(:name => context_name)
  @current_user.todos.create!(:context_id => context.id, :description => description)
end

Given /^I have a todo "([^"]*)"$/ do |description|
  Given "I have a todo \"#{description}\" in the context \"Context A\""
end

Given /^I have ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    Given "I have a todo \"todo #{i}\" in the context \"Context A\""
  end
end

Given /^I have ([0-9]+) deferred todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context B")
  count.to_i.downto 1 do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}", :show_from => @current_user.time + 1.week)
  end
end

Given /^I have a deferred todo "(.*)"$/ do |description|
  context = @current_user.contexts.create!(:name => "context B")
  @current_user.todos.create!(:context_id => context.id, :description => description, :show_from => @current_user.time + 1.week)
end

Given /^I have ([0-9]+) completed todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context C")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
    todo.complete!
  end
end

Given /^I have ([0-9]+) completed todos with a note$/ do |count|
  context = @current_user.contexts.create!(:name => "context D")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}", :notes => "note #{i}")
    todo.complete!
  end
end

Given /^I have a project "([^"]*)" that has the following todos$/ do |project_name, todos|
  Given "I have a project called \"#{project_name}\""
  @project.should_not be_nil
  todos.hashes.each do |todo|
    context = @current_user.contexts.find_by_name(todo[:context])
    context.should_not be_nil
    new_todo = @current_user.todos.create!(
      :description => todo[:description],
      :context_id => context.id,
      :project_id=>@project.id)
    unless todo[:tags].nil?
      new_todo.tag_with(todo[:tags])
    end
  end
end

When /I change the (.*) field of "([^\"]*)" to "([^\"]*)"$/ do |field_name, todo_name, new_value|
  todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil

  open_edit_form_for(todo)
  selenium.type("css=form.edit_todo_form input[name=#{field_name}]", new_value)
  submit_edit_todo_form(todo)
end

When /^I submit a new action with description "([^"]*)"$/ do |description|
  fill_in "todo[description]", :with => description
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  fill_in "todo[description]", :with => description
  fill_in "tag_list", :with => tags

  # fill_in does not seem to work when the field is prefilled with something. Empty the field first
  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name
  submit_next_action_form
end

When /^I submit a new deferred action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name

  fill_in "tag_list", :with => tags
  fill_in "todo[show_from]", :with => format_date(@current_user.time + 1.week)
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_project_name_from_next_action_form
  clear_context_name_from_next_action_form

  fill_in "todo_project_name", :with => project_name
  fill_in "todo_context_name", :with => context_name
  fill_in "tag_list", :with => tags

  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  fill_in "todo[description]", :with => description

  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name
  
  submit_next_action_form
end

When /^I submit multiple actions with using$/ do |multiple_actions|
  fill_in "todo[multiple_todos]", :with => multiple_actions
  submit_multiple_next_action_form
end

When /^I fill the multiple actions form with "([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)"$/ do |descriptions, project_name, context_name, tags|
  fill_in "todo[multiple_todos]", :with => descriptions
  fill_in "multi_todo_project_name", :with => project_name
  fill_in "multi_todo_context_name", :with => context_name
  fill_in "multi_tag_list", :with => tags
end

When /^I submit the new multiple actions form with "([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)"$/ do |descriptions, project_name, context_name, tags|
  When "I fill the multiple actions form with \"#{descriptions}\", \"#{project_name}\", \"#{context_name}\", \"#{tags}\""
  submit_multiple_next_action_form
end

When /^I submit the new multiple actions form with$/ do |multi_line_descriptions|
  fill_in "todo[multiple_todos]", :with => multi_line_descriptions
  submit_multiple_next_action_form
end

When /^I edit the due date of "([^"]*)" to tomorrow$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  fill_in "due_todo_#{todo.id}", :with => format_date(todo.created_at + 1.day)
  submit_edit_todo_form(todo)
end

When /^I clear the due date of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  selenium.click("//div[@id='edit_todo_#{todo.id}']//a[@id='due_x_todo_#{todo.id}']/img", :wait_for => :ajax, :javascript_framework => :jquery)
  submit_edit_todo_form(todo)
end

When /^I mark "([^"]*)" as complete$/ do |action_description|
  # TODO: generalize. this currently only works for projects wrt xpath
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  check "mark_complete_#{todo.id}"
  wait_for :timeout => 5 do
    !selenium.is_element_present("//div[@id='p#{todo.project.id}items']//div[@id='line_todo_#{todo.id}']")
  end
  # note that animations could be running after finishing this
end

When /^I delete the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  delete_todo_button = "xpath=//a[@id='delete_todo_#{todo.id}']/img"
  selenium.click delete_todo_button
  selenium.get_confirmation.should == "Are you sure that you want to delete the action '#{todo.description}'?"

  wait_for :timeout => 5 do
    !selenium.is_element_present("//div[@id='line_todo_#{todo.id}']")
  end
end

Then /^I should see ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    match_xpath "div["
  end
end

Then /^there should not be an error$/ do
  sleep(5)
  # form should be gone and thus no errors visible
  wait_for :timeout => 5 do
    !selenium.is_visible("edit_todo_#{@dep_todo.id}")
  end
end

Then /^I should see the todo "([^\"]*)"$/ do |todo_description|
  selenium.is_element_present("//span[.=\"#{todo_description}\"]").should be_true
end

Then /^I should not see the todo "([^\"]*)"$/ do |todo_description|
  selenium.is_element_present("//span[.=\"#{todo_description}\"]").should be_false
end

Then /^the number of actions should be (\d+)$/ do |count|
  @current_user.todos.count.should == count.to_i
end

Then /^the container for the context "([^"]*)" should be visible$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  xpath = "xpath=//div[@id=\"c#{context.id}\"]"
  selenium.wait_for_element(xpath, :timeout_in_seconds => 5)
  selenium.is_visible(xpath).should be_true
end

Then /^the container for the context "([^"]*)" should not be visible$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil

  wait_for_ajax

  xpath = "xpath=//div[@id=\"c#{context.id}\"]"
  selenium.is_element_present(xpath).should be_false
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  selenium.get_confirmation.should == "New context '#{context_name}' will be also created. Are you sure?"
end

Then /^I should see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should see "([^"]*)" in the action container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='p#{todo.project.id}items']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should see "([^"]*)" in the completed container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='completed_container']//div[@id='line_todo_#{todo.id}']"

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

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Project").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Context").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end
