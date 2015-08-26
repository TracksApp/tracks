When /^I select the second page$/ do
  step "I follow \"2\" within \"div.paginate_header\""
end

####### DELETE #######

When /^I delete the action "([^"]*)"$/ do |action_description|
  todo = find_todo(action_description)

  handle_js_confirm do
    open_submenu_for(todo) do
      click_link "delete_todo_#{todo.id}"
    end
  end
  expect(get_confirm_text).to eq("Are you sure that you want to delete the action '#{todo.description}'?")
  
  wait_for_ajax
end

When /^I delete the todo "([^"]*)"$/ do |action_description|
  step "I delete the action \"#{action_description}\""
end

####### Notes #######

When /^I open the notes of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.where(:description => action_description).first
  expect(todo).to_not be_nil

  page.find(:xpath, "//div[@id='line_todo_#{todo.id}']/div/a/img").click
  
  expect(page).to have_xpath("//div[@id='notes_todo_#{todo.id}']", :visible=>true)
end

####### THEN #######

Then /^I should see a starred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.where(:description => action_description).first
  expect(todo).to_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star starred']"
  expect(page).to have_xpath(xpath_starred)
end

Then /^I should see an unstarred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.where(:description => action_description).first
  expect(todo).to_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star']"
  expect(page).to have_xpath(xpath_starred)
end

Then /^I should see ([0-9]+) todos$/ do |count|
  total = page.all("div.item-container").inject(0) { |s, e| s+=1 }
  expect(total).to eq(count.to_i)
end

Then /^I should see the todo "([^\"]*)"$/ do |todo_description|
  expect(page).to have_xpath("//span[.=\"#{todo_description}\"]", :visible => true)
end

Then /^I should not see the todo "([^\"]*)"$/ do |todo_description|
  expect(page).to_not have_xpath("//span[.=\"#{todo_description}\"]", :visible => true)
end

Then /^I should see a completed todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil

  # only completed todos have a grey span with the completed_at date
  xpath = "//div[@id='line_todo_#{todo.id}']/div/span[@class='grey']"
  expect(page).to have_xpath(xpath, :visible=>true)
end

Then /^I should see an active todo "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil

  xpath = "//div[@id='line_todo_#{todo.id}']/img[@class='grip']"
  expect(page).to have_xpath(xpath, :visible=>true)
end

Then /^the number of actions should be (\d+)$/ do |count|
  expect(@current_user.todos.count).to eq(count.to_i)
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  expect(get_confirm_text).to eq("New context '#{context_name}' will be also created. Are you sure?")
end

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  if content.blank?
    expect(page.has_css?("select#todo_project_id option[selected='selected']")).to be false
  else
    expect(page.find("select#todo_project_id option[selected='selected']").text).to match(/#{content}/)
  end
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  if content.blank?
    expect(page.has_css?("select#todo_context_id option[selected='selected']")).to be false
  else
    expect(page.find("select#todo_context_id option[selected='selected']").text).to match(/#{content}/)
  end
end

Then /^I should see the page selector$/ do
  expect(page).to have_xpath(".//a[@class='next_page']")
end

Then /^the page should be "([^"]*)"$/ do |page_number|
  expect(page.find(:xpath, ".//div[@class='paginate_header']//em[@class='current']").text).to eq(page_number)
end

Then /^the project field of the new todo form should contain "([^"]*)"$/ do |project_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_project_name']"
  expect(page.find(:xpath, xpath).value).to eq(project_name)
end

Then /^the context field of the new todo form should contain "([^"]*)"$/ do |context_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_context_name']"
  expect(page.find(:xpath, xpath).value).to eq(context_name)
end

Then /^the default context of the new todo form should be "([^"]*)"$/ do |context_name|
  xpath= "//form[@id='todo-form-new-action']/input[@id='todo_context_name']"
  expect(context_name).to eq(page.find(:xpath, xpath).value)
end

Then /^the tag field in the new todo form should be empty$/ do
  xpath= "//form[@id='todo-form-new-action']/input[@id='tag_list']"
  expect(page.find(:xpath, xpath).value).to be_blank
end

Then /^the tag field in the new todo form should be "([^"]*)"$/ do |tag_list|
  xpath= "//form[@id='todo-form-new-action']/input[@id='tag_list']"
  expect(tag_list).to eq(page.find(:xpath, xpath).value)
end

Then /^the tags of "([^"]*)" should be "([^"]*)"$/ do |todo_description, tag_list|
  expect(find_todo(todo_description).tag_list).to eq(tag_list)
end

Then /^I should see "([^"]*)" in the completed section of the mobile site$/ do |desc|
  todo = @current_user.todos.where(:description => desc).first
  expect(todo).to_not be_nil

  xpath = "//div[@id='completed_container']//a[@href='/todos/#{todo.id}.m']"
  expect(page).to have_xpath(xpath)
end

Then /^I should (see|not see) the notes of "([^"]*)"$/ do |visible, todo_description|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo).to_not be_nil
  
  expect(page.find("div#notes_todo_#{todo.id}")).send(visible=="see" ? :to : :to_not, be_visible)
end

Then /^I should (see|not see) the empty tickler message$/ do |see|
  elem = find("div#no_todos_in_view")
  expect(elem).send(see=="see" ? :to : :to_not, be_visible)
end

Then /^I should see the todo "([^"]*)" with project name "([^"]*)"$/ do |todo_description, project_name|
  todo = @current_user.todos.where(:description => todo_description).first
  expect(todo.project.name).to eq(project_name)
end
