Given /^"([^"]*)" depends on "([^"]*)"$/ do |successor_name, predecessor_name|
  successor = Todo.where(:description => successor_name).first
  predecessor = Todo.where(:description => predecessor_name).first

  successor.add_predecessor(predecessor)
  successor.state = "pending"
  successor.save!
end

When /^I drag "(.*)" to "(.*)"$/ do |dragged, target|
  drag_id = Todo.where(:description => dragged).first.id
  drop_id = Todo.where(:description => target).first.id
  drag_elem = page.find(:xpath, "//div[@id='line_todo_#{drag_id}']//img[@class='grip']")
  drop_elem = page.find(:xpath, "//div[@id='line_todo_#{drop_id}']")

  drag_elem.drag_to(drop_elem)
end

When /^I expand the dependencies of "([^\"]*)"$/ do |todo_name|
  todo = Todo.where(:description=>todo_name).first
  expect(todo).to_not be_nil

  expand_img_locator = "//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  page.find(:xpath, expand_img_locator).click
  
  wait_for_animations_to_end
end

When /^I edit the dependency of "([^"]*)" to add "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil
  predecessor = @current_user.todos.where(:description => predecessor_description).first
  expect(predecessor).to_not be_nil

  open_edit_form_for(todo)

  form_css = "form#form_todo_#{todo.id}"
  within form_css do
    fill_in 'predecessor_input', :with => predecessor_description
  end

  # in webkit, the autocompleter is not fired after fill_in
  page.execute_script %Q{$("#{form_css}").find('input[id$="predecessor_input"]').autocomplete('search')} if Capybara.javascript_driver == :webkit
  
  # wait for auto complete
  expect(page).to have_css("a.ui-state-focus")

  # click first line
  page.find(:css, "ul li a.ui-state-focus").click

  # wait for the new dependency to be added to the list
  expect(page).to have_css("li#pred_#{predecessor.id}")

  submit_edit_todo_form(todo)
end

When /^I edit the dependency of "([^"]*)" to remove "([^"]*)" as predecessor$/ do |todo_description, predecessor_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil
  predecessor = @current_user.todos.where(:description => predecessor_description).first
  expect(predecessor).to_not be_nil

  open_edit_form_for(todo)

  delete_dep_button = "//form[@id='form_todo_#{todo.id}']//img[@id='delete_dep_#{predecessor.id}']"
  page.find(:xpath, delete_dep_button).click
  
  expect(page).to_not have_xpath(delete_dep_button)

  submit_edit_todo_form(todo)
  wait_for_ajax
  wait_for_animations_to_end
end

When /^I edit the dependency of "([^"]*)" to "([^"]*)"$/ do |todo_name, deps|
  todo = @dep_todo = @current_user.todos.where(:description => todo_name).first
  expect(todo).to_not be_nil

  open_edit_form_for(todo)
  fill_in "predecessor_list_todo_#{todo.id}", :with => deps
  submit_edit_todo_form(todo)
end

Then /^the successors of "(.*)" should include "(.*)"$/ do |parent_name, child_name|
  parent = @current_user.todos.where(:description => parent_name).first
  expect(parent).to_not be_nil

  # wait until the successor is added.
  wait_until do
    !parent.pending_successors.where(:description => child_name).first.nil?
  end
end

Then /^I should see "([^\"]*)" within the dependencies of "([^\"]*)"$/ do |successor_description, todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil

  # open successors
  within "div#line_todo_#{todo.id}" do
    if !find(:css, "div#successors_todo_#{todo.id}").visible?
      find(:css, "a.show_successors").click
    end
  end

  step "I should see \"#{successor_description}\" within \"div#line_todo_#{todo.id}\""
end

Then /^I should not see "([^"]*)" within the dependencies of "([^"]*)"$/ do |successor_description, todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil
  
  step "I should not see \"#{successor_description}\" within \"div#line_todo_#{todo.id}\""
end

Then /^I should see that "([^"]*)" does not have dependencies$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil
  dependencies_icon = "//div[@id='line_todo_#{todo.id}']/div/a[@class='show_successors']/img"
  expect(page).to_not have_xpath(dependencies_icon)
end
