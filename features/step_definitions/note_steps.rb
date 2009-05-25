Given /^I have two projects with one note each$/ do
  project_a = @current_user.projects.create!(:name => 'project A')
  project_a.notes.create!(:user_id => @current_user.id, :body => 'note for project A')
  project_b = @current_user.projects.create!(:name => 'project B')
  project_b.notes.create!(:user_id => @current_user.id, :body => 'note for project B')
end

Then /^(.*) notes should be visible$/ do |number|
  # count number of project_notes
  count = 0
  response.should have_xpath("//div[@class='project_notes']") { |nodes|  nodes.each { |n| count += 1 }}
  count.should  == number.to_i
end

When /^I click Toggle Notes$/ do
  click_link 'Toggle notes'
end

Given /^I have one project "([^\"]*)" with no notes$/ do |project_name|
  @current_user.projects.create!(:name => project_name)
end

When /^I add note "([^\"]*)" from the "([^\"]*)" project page$/ do |note, project|
  project = Project.find_by_name(project)
  project.notes.create!(:user_id => @current_user.id, :body => note)
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

Given /^I have a project "([^\"]*)" with (.*) notes?$/ do |project_name, num|
  project = @current_user.projects.create!(:name => project_name)
  num.to_i.downto 0 do |i|
    project.notes.create!(:user_id => @current_user.id, :body => "A note #{i}")
  end
end

When /^I delete the first note$/ do
  # need selenium for this to check on the js
  pending
end

Given /^I have one project "([^\"]*)" with 1 note$/ do |arg1|
  pending
end

When /^I click the icon next to the note$/ do
  # need selenium for this to check on the js
  pending
end

Then /^I should see the note text$/ do
  # need selenium for this to check on the js
  pending
end

Then /^I should see the body of the notes$/ do
  pending
end


#------ left over from old stories. can be removed if pending stuff is done

When "Luis adds a note from the Pass Final Exam project page" do
When "Luis visits the Pass Final Exam project page"
clicks_link 'Add a note', :wait => :ajax
fills_in 'new_note_body', :with => 'new exam note'
clicks_button 'Add note', :wait => :ajax
end

When "Luis deletes the first note" do
selenium.click "css=a.delete_note"
selenium.get_confirmation.should =~ /delete/
end

When "clicks the icon next to the note" do
selenium.click "css=a.link_to_notes"
wait_for_page_to_load
end

When "Luis clicks Toggle Notes" do
clicks_link 'Toggle notes', :wait => :effects
end

Then "Luis should see the note on the Pass Final Exam project page" do
should_see "new exam note"
end

Then "Luis should see the note on the notes page" do
visits '/notes'
should_see "new exam note"
end

Then "the first note should disappear" do
wait_for_ajax_and_effects
should_not_see 'exam note 1'
end


Then "he should see the note text" do
should_see 'exam note 1'
end
