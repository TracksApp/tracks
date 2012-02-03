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
  drag_elem = page.find(:xpath, "//div[@id='line_todo_#{drag_id}']//img[@class='grip']")
  drop_elem = page.find(:xpath, "//div[@id='line_todo_#{drop_id}']//div[@class='description']")

  drag_elem.drag_to(drop_elem)
end

When /^I expand the dependencies of "([^\"]*)"$/ do |todo_name|
  todo = Todo.find_by_description(todo_name)
  todo.should_not be_nil

  expand_img_locator = "//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  page.find(:xpath, expand_img_locator).click
  
  wait_for_animations_to_end
end

When /^I edit the dependency of "([^"]*)" to add "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  predecessor = @current_user.todos.find_by_description(predecessor_description)
  predecessor.should_not be_nil

  open_edit_form_for(todo)

  form_css = "form#form_todo_#{todo.id}"
  
  within form_css do
    fill_in 'predecessor_input', :with => predecessor_description
  end

  # in webkit, the autocompleter is not fired after fill_in
  page.execute_script %Q{$("#{form_css}").find('input[id$="predecessor_input"]').autocomplete('search')} if Capybara.javascript_driver == :webkit
  
  # wait for auto complete
  page.should have_css("a#ui-active-menuitem")

  # click first line
  page.find(:xpath, "//ul/li[1]/a[@id='ui-active-menuitem']").click

  # wait for the new dependency to be added to the list
  page.should have_css("li#pred_#{predecessor.id}")

  submit_edit_todo_form(todo)
end

When /^I edit the dependency of "([^"]*)" to remove "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  predecessor = @current_user.todos.find_by_description(predecessor_description)
  predecessor.should_not be_nil

  open_edit_form_for(todo)

  delete_dep_button = "//form[@id='form_todo_#{todo.id}']//img[@id='delete_dep_#{predecessor.id}']"
  page.find(:xpath, delete_dep_button).click
  
  page.should_not have_xpath(delete_dep_button)

  submit_edit_todo_form(todo)
  wait_for_ajax
  wait_for_animations_to_end
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

  Then "I should see \"#{successor_description}\" within \"div#line_todo_#{todo.id}\""
end

Then /^I should not see "([^"]*)" within the dependencies of "([^"]*)"$/ do |successor_description, todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  
  Then "I should not see \"#{successor_description}\" within \"div#line_todo_#{todo.id}\""
end

Then /^I should see that "([^"]*)" does not have dependencies$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  dependencies_icon = "//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  page.should_not have_xpath(dependencies_icon)
end

