####### DELETE #######

When /^I delete the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  handle_js_confirm do
    open_submenu_for(todo)
    find("a#delete_todo_#{todo.id}").click
  end
  get_confirm_text.should == "Are you sure that you want to delete the action '#{todo.description}'?"
  
  wait_for_ajax
  wait_for_animations_to_end
end

When /^I delete the todo "([^"]*)"$/ do |action_description|
  When "I delete the action \"#{action_description}\""
end

####### Notes #######

When /^I open the notes of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  show_notes_img = "xpath=//div[@id='line_todo_#{todo.id}']/div/a/img"
  selenium.click show_notes_img

  wait_for :timeout => 5 do
    selenium.is_visible "//div[@id='notes_todo_#{todo.id}']"
  end
end

####### THEN #######

Then /^I should see a starred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star starred']"

  selenium.is_element_present(xpath_starred).should be_true
end

Then /^I should see an unstarred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath_starred)
  end
end

Then /^I should see ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    match_xpath "div["
  end
end

Then /^there should not be an error$/ do
  # form should be gone and thus no errors visible
  wait_for :timeout => 5 do
    !selenium.is_visible("edit_todo_#{@dep_todo.id}")
  end
end

Then /^I should see the todo "([^\"]*)"$/ do |todo_description|
  selenium.is_element_present("//span[.=\"#{todo_description}\"]").should be_true
end

Then /^I should not see the todo "([^\"]*)"$/ do |todo_description|
  xpath = "//span[.=\"#{todo_description}\"]"
  if selenium.is_element_present(xpath)
    wait_for :timeout => 5 do
      !selenium.is_element_present(xpath)
    end
  end
end

Then /^I should see a completed todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  # only completed todos have a grey span with the completed_at date
  xpath = "//div[@id='line_todo_#{todo.id}']/div/span[@class='grey']"

  unless selenium.is_element_present(xpath)
    wait_for :timeout => 5 do
      selenium.is_element_present(xpath)
    end
  end
  selenium.is_visible(xpath).should be_true

end

Then /^I should see an active todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  # only active todos have a grip div

  xpath = "//div[@id='line_todo_#{todo.id}']/img[@class='grip']"

  unless selenium.is_element_present(xpath)
    wait_for :timeout => 5 do
      selenium.is_element_present(xpath)
    end
  end
  selenium.is_visible(xpath).should be_true
end

Then /^the number of actions should be (\d+)$/ do |count|
  @current_user.todos.count.should == count.to_i
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  selenium.get_confirmation.should == "New context '#{context_name}' will be also created. Are you sure?"
end

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Project").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Context").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end

Then /^I should see the page selector$/ do
  page_selector_xpath = ".//a[@class='next_page']"
  response.body.should have_xpath(page_selector_xpath)
end

Then /^the page should be "([^"]*)"$/ do |page_number|
  page_number_found = -1
  page_number_xpath = ".//span[@class='current']"
  response.should have_xpath(page_number_xpath) do |node|
    page_number_found = node.first.content.to_i
  end
  page_number_found.should == page_number.to_i
end

Then /^the project field of the new todo form should contain "([^"]*)"$/ do |project_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_project_name']"
  project_name.should == response.selenium.get_value("xpath=#{xpath}")
end

Then /^the default context of the new todo form should be "([^"]*)"$/ do |context_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_context_name']"
  context_name.should == response.selenium.get_value("xpath=#{xpath}")
end

Then /^the tag field in the new todo form should be empty$/ do
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_tag_list']"
  assert response.selenium.get_value("xpath=#{xpath}").blank?
end

Then /^the tag field in the new todo form should be "([^"]*)"$/ do |tag_list|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_tag_list']"
  tag_list.should == response.selenium.get_value("xpath=#{xpath}")
end

Then /^the tags of "([^"]*)" should be "([^"]*)"$/ do |todo_description, tag_list|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  todo.tag_list.should == tag_list
end

Then /^I should see "([^"]*)" in the completed section of the mobile site$/ do |desc|
  todo = @current_user.todos.find_by_description(desc)
  todo.should_not be_nil

  xpath = "//div[@id='completed_container']//a[@href='/todos/#{todo.id}.m']"
  response.should have_xpath xpath
end
