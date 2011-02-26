Given /^I have no todos$/ do
  Todo.delete_all
end

Given /^I have a todo "(.*)"$/ do |description|
  context = @current_user.contexts.create!(:name => "context A")
  @current_user.todos.create!(:context_id => context.id, :description => description)
end

Given /^I have ([0-9]+) todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context A")
  count.to_i.downto 1 do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
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

Given /^"(.*)" depends on "(.*)"$/ do |successor_name, predecessor_name|
  successor = Todo.find_by_description(successor_name)
  predecessor = Todo.find_by_description(predecessor_name)
  
  successor.add_predecessor(predecessor)
  successor.state = "pending"
  successor.save!
end

Given /^I have a project "([^"]*)" that has the following todos$/ do |project_name, todos|
  Given "I have a project called \"#{project_name}\""
  @project.should_not be_nil
  todos.hashes.each do |todo|
    context_id = @current_user.contexts.find_by_name(todo[:context])
    context_id.should_not be_nil
    @current_user.todos.create!(
      :description => todo[:description],
      :context_id => context_id,
      :project_id=>@project.id)
  end
end

When /^I drag "(.*)" to "(.*)"$/ do |dragged, target|
  drag_id = Todo.find_by_description(dragged).id
  drop_id = Todo.find_by_description(target).id
  drag_name = "xpath=//div[@id='line_todo_#{drag_id}']//img[@class='grip']"
  drop_name = "xpath=//div[@id='line_todo_#{drop_id}']//div[@class='description']"
  
  selenium.drag_and_drop_to_object(drag_name, drop_name)

  arrow = "xpath=//div[@id='line_todo_#{drop_id}']/div/a[@class='show_successors']/img"
  selenium.wait_for_element(arrow, :timeout_in_seconds => 5)
end

When /^I expand the dependencies of "([^\"]*)"$/ do |todo_name|
  todo = Todo.find_by_description(todo_name)
  todo.should_not be_nil

  expand_img_locator = "xpath=//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  selenium.click(expand_img_locator)
end

When /I change the (.*) field of "([^\"]*)" to "([^\"]*)"$/ do |field, todo_name, new_value|
  todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil

  selenium.click("//img[@id='edit_icon_todo_#{todo.id}']", :wait_for => :ajax, :javascript_framework => :jquery)
  selenium.type("css=form.edit_todo_form input[name=#{field}]", new_value)
  selenium.click("css=button.positive", :wait_for => :ajax, :javascript_framework => :jquery)
  # TODO: change to a wait_for
  sleep(5)
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

When /^I edit the dependency of "([^"]*)" to "([^"]*)"$/ do |todo_name, deps|
  todo = @dep_todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil
  # click edit
  selenium.click("//div[@id='line_todo_#{todo.id}']//img[@id='edit_icon_todo_#{todo.id}']", :wait_for => :ajax, :javascript_framework => :jquery)
  fill_in "predecessor_list_todo_#{todo.id}", :with => deps
  
  submit_edit_todo_form(todo)
  sleep(1) # TODO: replace with some wait_for
end

Then /^I should see ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    match_xpath "div["
  end
end

Then /^there should not be an error$/ do
  sleep(5)
  # form should be gone and thus no errors visible
  selenium.is_visible("edit_todo_#{@dep_todo.id}").should == false
end

Then /^the successors of "(.*)" should include "(.*)"$/ do |parent_name, child_name|
  parent = @current_user.todos.find_by_description(parent_name)
  parent.should_not be_nil
  
  child = parent.pending_successors.find_by_description(child_name)
  child.should_not be_nil
end

Then /^I should see "([^\"]*)" within the dependencies of "([^\"]*)"$/ do |successor_description, todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  successor = @current_user.todos.find_by_description(successor_description)
  successor.should_not be_nil

  # argh, webrat on selenium does not support within, so this won't work
  # xpath = "//div[@id='line_todo_#{todo.id}'"
  # Then "I should see \"#{successor_description}\" within \"xpath=#{xpath}\""

  # let selenium look for the presence of the successor
  xpath = "xpath=//div[@id='line_todo_#{todo.id}']//div[@id='successor_line_todo_#{successor.id}']//span"
  selenium.wait_for_element(xpath, :timeout_in_seconds => 5)
end

Then /^I should not see "([^"]*)" within the dependencies of "([^"]*)"$/ do |successor_description, todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  successor = @current_user.todos.find_by_description(successor_description)
  successor.should_not be_nil
  # let selenium look for the presence of the successor
  xpath = "xpath=//div[@id='line_todo_#{todo.id}']//div[@id='successor_line_todo_#{successor.id}']//span"
  selenium.is_element_present(xpath).should be_false
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
  xpath = "xpath=//div[@id=\"c#{context.id}\"]"
  selenium.wait_for :wait_for => :ajax, :javascript_framework => :jquery
  selenium.is_element_present(xpath).should be_false
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  selenium.get_confirmation.should == "New context '#{context_name}' will be also created. Are you sure?"
end

Then /^I should see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  selenium.is_element_present(xpath).should be_true
end

Then /^I should not see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  selenium.is_element_present(xpath).should be_false
end

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Project").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Context").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end
