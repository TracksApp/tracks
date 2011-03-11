Given /^"([^"]*)" depends on "([^"]*)"$/ do |successor_name, predecessor_name|
  successor = Todo.find_by_description(successor_name)
  predecessor = Todo.find_by_description(predecessor_name)

  successor.add_predecessor(predecessor)
  successor.state = "pending"
  successor.save!
end

When /^I drag "(.*)" to "(.*)"$/ do |dragged, target|
  drag_id = Todo.find_by_description(dragged).id
  drop_id = Todo.find_by_description(target).id
  drag_name = "xpath=//div[@id='line_todo_#{drag_id}']//img[@class='grip']"
  drop_name = "xpath=//div[@id='line_todo_#{drop_id}']//div[@class='description']"

  selenium.drag_and_drop_to_object(drag_name, drop_name)

  wait_for_ajax
end

When /^I expand the dependencies of "([^\"]*)"$/ do |todo_name|
  todo = Todo.find_by_description(todo_name)
  todo.should_not be_nil

  expand_img_locator = "xpath=//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  selenium.click(expand_img_locator)
end

When /^I edit the dependency of "([^"]*)" to add "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  predecessor = @current_user.todos.find_by_description(predecessor_description)
  predecessor.should_not be_nil

  open_edit_form_for(todo)

  input = "xpath=//form[@id='form_todo_#{todo.id}']//input[@id='predecessor_input']"
  selenium.focus(input)
  selenium.type_keys input, predecessor_description

  # wait for auto complete
  autocomplete = "xpath=//a[@id='ui-active-menuitem']"
  selenium.wait_for_element(autocomplete, :timeout_in_seconds => 5)

  # click first line
  first_elem = "xpath=//ul/li[1]/a[@id='ui-active-menuitem']"
  selenium.click(first_elem)

  new_dependency_line = "xpath=//li[@id='pred_#{predecessor.id}']"
  selenium.wait_for_element(new_dependency_line, :timeout_in_seconds => 5)

  submit_edit_todo_form(todo)
end

When /^I edit the dependency of "([^"]*)" to remove "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  predecessor = @current_user.todos.find_by_description(predecessor_description)
  predecessor.should_not be_nil

  open_edit_form_for(todo)

  delete_dep_button = "xpath=//form[@id='form_todo_#{todo.id}']//img[@id='delete_dep_#{predecessor.id}']"
  selenium.click(delete_dep_button)
  wait_for :timeout=>5 do
    !selenium.is_element_present(delete_dep_button)
  end
  
  submit_edit_todo_form(todo)
  # note that animations will be running after the ajax is completed
end

When /^I edit the dependency of "([^"]*)" to "([^"]*)"$/ do |todo_name, deps|
  todo = @dep_todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil

  open_edit_form_for(todo)
  fill_in "predecessor_list_todo_#{todo.id}", :with => deps
  submit_edit_todo_form(todo)
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
  wait_for :timeout => 5 do
    !selenium.is_element_present(xpath)
  end
end
