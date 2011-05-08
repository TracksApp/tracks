When /I change the (.*) field of "([^\"]*)" to "([^\"]*)"$/ do |field_name, todo_name, new_value|
  todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil

  open_edit_form_for(todo)
  selenium.type("css=form.edit_todo_form input[name=#{field_name}]", new_value)
  submit_edit_todo_form(todo)
end

When /^I edit the context of "([^"]*)" to "([^"]*)"$/ do |context_old_name, context_new_name|
  When "I change the context_name field of \"#{context_old_name}\" to \"#{context_new_name}\""
end

When /^I edit the description of "([^"]*)" to "([^"]*)"$/ do |action_description, new_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  fill_in "todo_description", :with => new_description
  submit_edit_todo_form(todo)
end

When /^I edit the due date of "([^"]*)" to tomorrow$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  fill_in "due_todo_#{todo.id}", :with => format_date(todo.created_at + 1.day)
  submit_edit_todo_form(todo)
end

When /^I edit the due date of "([^"]*)" to next month$/ do  |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  fill_in "due_todo_#{todo.id}", :with => format_date(todo.created_at + 1.month)
  submit_edit_todo_form(todo)
end

When /^I clear the due date of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  open_edit_form_for(todo)
  selenium.click("//div[@id='edit_todo_#{todo.id}']//a[@id='due_x_todo_#{todo.id}']/img", :wait_for => :ajax, :javascript_framework => :jquery)
  submit_edit_todo_form(todo)
end

When /^I remove the show from date from "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  
  open_edit_form_for(todo)
  selenium.click("//div[@id='edit_todo_#{todo.id}']//a[@id='show_from_x_todo_#{todo.id}']/img", :wait_for => :ajax, :javascript_framework => :jquery)
  
  submit_edit_todo_form(todo)
end
