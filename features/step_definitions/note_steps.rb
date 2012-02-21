Given /^I have one project "([^\"]*)" with no notes$/ do |project_name|
  @current_user.projects.create!(:name => project_name)
end

Given /^I have two projects with one note each$/ do
  project_a = @current_user.projects.create!(:name => 'project A')
  project_a.notes.create!(:user_id => @current_user.id, :body => 'note for project A')
  project_b = @current_user.projects.create!(:name => 'project B')
  project_b.notes.create!(:user_id => @current_user.id, :body => 'note for project B')
end

Given /^I have a project "([^\"]*)" with (.*) notes?$/ do |project_name, num|
  project = @current_user.projects.create!(:name => project_name)
  1.upto num.to_i do |i|
    project.notes.create!(:user_id => @current_user.id, :body => "A note #{i}. This is the very long body of note #{i} where you should not see the last part of the note after 50 characters")
  end
end

When /^I add note "([^\"]*)" from the "([^\"]*)" project page$/ do |note, project|
  project = Project.find_by_name(project)
  project.notes.create!(:user_id => @current_user.id, :body => note)
end

When /^I delete the first note$/ do
  title = page.find("div.container h2").text
  id = title.split(' ').last

  handle_js_confirm do
    click_link "delete_note_#{id}"
  end
  get_confirm_text.should == "Are you sure that you want to delete the note '#{id}'?"
end

When /^I click the icon next to the note$/ do
  click_link "Show note"
end

When /^I edit the first note to "([^"]*)"$/ do |note_body|
  title = page.find("div.container h2").text
  id = title.split(' ').last
  
  click_link "link_edit_note_#{id}"
  fill_in "note[body]", :with => note_body
  click_button "submit_note_#{id}"
end

When /^I toggle the note of "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='line_todo_#{todo.id}']/div/a/img"

  page.find(:xpath, xpath).click
end

When /^I click Toggle Notes$/ do
  click_link 'Toggle notes'
end

When /^I toggle all notes$/ do
  step "I click Toggle Notes"
end

Then /^(.*) notes should be visible$/ do |number|
  # count number of project_notes
  count = 0
  page.all("div.project_notes").each { |node| count += 1 }
  count.should  == number.to_i
end

Then /^I should see note "([^\"]*)" on the "([^\"]*)" project page$/ do |note, project|
  project = Project.find_by_name(project)
  visit project_path(project)
  step "I should see the note \"#{note}\""
end

Then /^I should see note "([^\"]*)" on the notes page$/ do |note|
  visit notes_path
  step "I should see the note \"#{note}\""
end

Then /^the first note should disappear$/ do
  title = page.find("div.container h2").text
  id = title.split(' ').last
  note = "div#note_#{id}"
  
  wait_until do
    !page.has_selector?(note)
  end
end

Then /^I should see the note text$/ do
  step "I should see the note \"after 50 characters\""
end

Then /^I should not see the note "([^"]*)"$/ do |note_content|
  if page.has_selector?("div", :text => note_content)
    page.find("div", :text => note_content).visible?.should be_false
  end
end

Then /^I should see the note "([^"]*)"$/ do |note_content|
  page.find("div", :text => note_content).visible?.should be_true
end

