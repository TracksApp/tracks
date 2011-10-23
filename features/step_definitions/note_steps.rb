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
  title = selenium.get_text("css=div.container h2")
  id = title.split(' ').last
  click_link "delete_note_#{id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the note '#{id}'?"
end

When /^I click the icon next to the note$/ do
  click_link "Show note"
end

When /^I edit the first note to "([^"]*)"$/ do |note_body|
  title = selenium.get_text("css=div.container h2")
  id = title.split(' ').last
  click_link "link_edit_note_#{id}"
  fill_in "note[body]", :with => note_body
  click_button "submit_note_#{id}"
end

When /^I toggle the note of "([^"]*)"$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='line_todo_#{todo.id}']/div/a/img"

  selenium.click(xpath)
end

When /^I click Toggle Notes$/ do
  click_link 'Toggle notes'
end

When /^I toggle all notes$/ do
  When "I click Toggle Notes"
end

Then /^(.*) notes should be visible$/ do |number|
  # count number of project_notes
  count = 0
  response.should have_xpath("//div[@class='project_notes']") { |nodes|  nodes.each { |n| count += 1 }}
  count.should  == number.to_i
end

Then /^I should see note "([^\"]*)" on the "([^\"]*)" project page$/ do |note, project|
  project = Project.find_by_name(project)
  visit project_path(project)
  Then "I should see \"#{note}\""
end

Then /^I should see note "([^\"]*)" on the notes page$/ do |note|
  visit notes_path
  Then "I should see \"#{note}\""
end

Then /^the first note should disappear$/ do
  title = selenium.get_text("css=div.container h2")
  id = title.split(' ').last
  wait_for :timeout => 15 do
    !selenium.is_element_present("note_#{id}")
  end
end

Then /^I should see the note text$/ do
  Then "I should see \"after 50 characters\""
end