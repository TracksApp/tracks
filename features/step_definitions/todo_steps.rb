When /^I select the second page$/ do
  step "I follow \"2\" within \"div.paginate_header\""
end

####### DELETE #######

When /^I delete the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  handle_js_confirm do
    open_submenu_for(todo)
    click_link "delete_todo_#{todo.id}"
  end
  get_confirm_text.should == "Are you sure that you want to delete the action '#{todo.description}'?"
  
  wait_for_ajax
  # commented out: the notice is gone if you want to check for it
  # wait_for_animations_to_end
end

When /^I delete the todo "([^"]*)"$/ do |action_description|
  step "I delete the action \"#{action_description}\""
end

####### Notes #######

When /^I open the notes of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  page.find(:xpath, "//div[@id='line_todo_#{todo.id}']/div/a/img").click
  
  page.should have_xpath("//div[@id='notes_todo_#{todo.id}']", :visible=>true)
end

####### THEN #######

Then /^I should see a starred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star starred']"
  page.should have_xpath(xpath_starred)
end

Then /^I should see an unstarred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star']"
  page.should have_xpath(xpath_starred)
end

Then /^I should see ([0-9]+) todos$/ do |count|
  total = page.all("div.item-container").inject(0) { |s, e| s+=1 }
  total.should == count.to_i
end

Then /^I should see the todo "([^\"]*)"$/ do |todo_description|
  page.should have_xpath("//span[.=\"#{todo_description}\"]", :visible => true)
end

Then /^I should not see the todo "([^\"]*)"$/ do |todo_description|
  page.should_not have_xpath("//span[.=\"#{todo_description}\"]", :visible => true)
end

Then /^I should see a completed todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  # only completed todos have a grey span with the completed_at date
  xpath = "//div[@id='line_todo_#{todo.id}']/div/span[@class='grey']"
  page.should have_xpath(xpath, :visible=>true)
end

Then /^I should see an active todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='line_todo_#{todo.id}']/img[@class='grip']"
  page.should have_xpath(xpath, :visible=>true)
end

Then /^the number of actions should be (\d+)$/ do |count|
  @current_user.todos.count.should == count.to_i
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  get_confirm_text.should == "New context '#{context_name}' will be also created. Are you sure?"
end

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  if content.blank?
    page.has_css?("select#todo_project_id option[selected='selected']").should be_false
  else
    page.find("select#todo_project_id option[selected='selected']").text.should =~ /#{content}/
  end
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  if content.blank?
    page.has_css?("select#todo_context_id option[selected='selected']").should be_false
  else
    page.find("select#todo_context_id option[selected='selected']").text.should =~ /#{content}/
  end
end

Then /^I should see the page selector$/ do
  page.should have_xpath(".//a[@class='next_page']")
end

Then /^the page should be "([^"]*)"$/ do |page_number|
  page.find(:xpath, ".//div[@class='paginate_header']//em[@class='current']").text.should == page_number
end

Then /^the project field of the new todo form should contain "([^"]*)"$/ do |project_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_project_name']"
  project_name.should == page.find(:xpath, xpath).value
end

Then /^the default context of the new todo form should be "([^"]*)"$/ do |context_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_context_name']"
  context_name.should == page.find(:xpath, xpath).value
end

Then /^the tag field in the new todo form should be empty$/ do
  xpath= "//form[@id='todo-form-new-action']/input[@id='tag_list']"
  page.find(:xpath, xpath).value.blank?.should be_true
end

Then /^the tag field in the new todo form should be "([^"]*)"$/ do |tag_list|
  xpath= "//form[@id='todo-form-new-action']/input[@id='tag_list']"
  tag_list.should == page.find(:xpath, xpath).value
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
  page.should have_xpath(xpath)
end

Then /^I should (see|not see) empty message for (completed todos|todos) of home/ do |visible, kind_of_todo|
  elem = find(kind_of_todo=="todos" ? "div#no_todos_in_view" : "div#empty-d")
  elem.send(visible=="see" ? "should" : "should_not", be_visible)
end

Then /^I should (see|not see) the empty tickler message$/ do |see|
  elem = find("div#tickler-empty-nd")
  elem.send(see=="see" ? "should" : "should_not", be_visible)
end

Then /^I should (see|not see) the notes of "([^"]*)"$/ do |visible, todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil
  
  page.find("div#notes_todo_#{todo.id}").send(visible=="see" ? "should" : "should_not", be_visible)
end
