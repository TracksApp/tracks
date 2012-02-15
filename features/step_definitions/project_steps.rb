Given /^I have an outdated project "([^"]*)" with (\d+) todos$/ do |project_name, num_todos|
  Given "I have a project \"#{project_name}\" with #{num_todos} todos"
  @project = @current_user.projects.find_by_name(project_name)
  @project.last_reviewed = @current_user.time - @current_user.prefs.review_period.days-1
  @project.save
end

Given /^I have a project "([^\"]*)" with ([0-9]+) todos$/ do |project_name, num_todos|
  @context = @current_user.contexts.find_or_create_by_name("Context A")
  @project = @current_user.projects.create!(:name => project_name)
  # acts_as_list adds at top by default, but that is counter-intuitive when reading scenario's, so reverse this
  @project.move_to_bottom

  @todos=[]
  1.upto num_todos.to_i do |i|
    todo = @current_user.todos.create!(
      :project_id => @project.id,
      :context_id => @context.id,
      :description => "todo #{i}")
    @todos << todo
  end
end

Given /^I have a project "([^\"]*)" with ([0-9]+) deferred todos$/ do |project_name, num_todos|
  step "I have a project \"#{project_name}\" with #{num_todos} todos"
  @todos.each do |todo|
    todo.show_from = Time.zone.now + 1.week
    todo.save!
  end
end

Given /^there exists a project "([^\"]*)" for user "([^\"]*)"$/ do |project_name, user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil
  @project = user.projects.create!(:name => project_name)
  # acts_as_list adds at top by default, but that is counter-intuitive when reading scenario's, so reverse this
  @project.move_to_bottom
end

Given /^there exists a project called "([^"]*)" for user "([^"]*)"$/ do |project_name, login|
  # TODO: regexp change to integrate this with the previous since only 'called' is different
  step "there exists a project \"#{project_name}\" for user \"#{login}\""
end

Given /^I have a project called "([^"]*)"$/ do |project_name|
  step "there exists a project \"#{project_name}\" for user \"#{@current_user.login}\""
end

Given /^I have a project "([^"]*)" with a default context of "([^"]*)"$/ do |project_name, context_name|
  step "there exists a project \"#{project_name}\" for user \"#{@current_user.login}\""
  context = @current_user.contexts.create!(:name => context_name)
  @project.default_context = context
  @project.save!
end

Given /^I have the following projects:$/ do |table|
  table.hashes.each do |project|
    step 'I have a project called "'+project[:project_name]+'"'
    # acts_as_list puts the last added project at the top, but we want it
    # at the bottom to be consistent with the table in the scenario
    @project.move_to_bottom
    @project.save!
  end
end

Given /^I have a completed project called "([^"]*)"$/ do |project_name|
  step "I have a project called \"#{project_name}\""
  @project.complete!
  @project.reload
  assert @project.completed?
end

Given /^I have (\d+) completed projects$/ do |number_of_projects|
  1.upto number_of_projects.to_i do |i|
    step "I have a completed project called \"Project #{i}\""
  end
end

Given /^I have no projects$/ do
  Project.delete_all
end

Given /^I have a hidden project called "([^"]*)"$/ do |project_name|
  @project = @current_user.projects.create!(:name => project_name)
  @project.hide!
end

When /^I open the project edit form$/ do
  click_link "link_edit_project_#{@project.id}"

  wait_for do
    selenium.is_element_present("submit_project_#{@project.id}")
  end
end

When /^I cancel the project edit form$/ do
  click_link "cancel_project_#{@project.id}"

  if selenium.is_visible("submit_project_#{@project.id}")
    wait_for do
      !selenium.is_visible("submit_project_#{@project.id}")
    end
  end
end

When /^I edit the project description to "([^\"]*)"$/ do |new_description|
  click_link "link_edit_project_#{@project.id}"
  fill_in "project[description]", :with => new_description
  click_button "submit_project_#{@project.id}"

  wait_for do
    !selenium.is_element_present("submit_project_#{@project.id}")
  end
end

When /^I edit the project name to "([^\"]*)"$/ do |new_title|
  click_link "link_edit_project_#{@project.id}"

  wait_for do
    selenium.is_element_present("submit_project_#{@project.id}")
  end

  fill_in "project[name]", :with => new_title

  selenium.click "submit_project_#{@project.id}",
    :wait_for => :text,
    :text => "Project saved",
    :timeout => 5

  wait_for do
    !selenium.is_element_present("submit_project_#{@project.id}")
  end
end

When /^I try to edit the project name to "([^\"]*)"$/ do |new_title|
  click_link "link_edit_project_#{@project.id}"

  wait_for do
    selenium.is_element_present("submit_project_#{@project.id}")
  end

  fill_in "project[name]", :with => new_title

  selenium.click "submit_project_#{@project.id}",
    :wait_for => :text,
    :text => "There were problems with the following fields:",
    :timeout => 5
end

When /^I edit the default context to "([^"]*)"$/ do |default_context|
  click_link "link_edit_project_#{@project.id}"

  wait_for do
    selenium.is_element_present("submit_project_#{@project.id}")
  end

  fill_in "project[default_context_name]", :with => default_context

  selenium.click "submit_project_#{@project.id}",
    :wait_for => :text,
    :text => "Project saved",
    :timeout => 5

  wait_for :timeout => 5 do
    !selenium.is_element_present("submit_project_#{@project.id}")
  end
end

Then /^I should not see empty message for project todos/ do
  find("div#p#{@project.id}empty-nd").should_not be_visible
end

Then /^I should see empty message for project todos/ do
  find("div#p#{@project.id}empty-nd").should be_visible
end

Then /^I should not see empty message for project deferred todos/ do
  find("div#tickler-empty-nd").should_not be_visible
end

Then /^I should see empty message for project deferred todos/ do
  find("div#tickler-empty-nd").should be_visible
end

Then /^I should not see empty message for project completed todos$/ do
  find("div#empty-d").should_not be_visible
end

When /^I should see empty message for project completed todos$/ do
  find("div#empty-d").should be_visible
end

Then /^I edit the default tags to "([^"]*)"$/ do |default_tags|
  click_link "link_edit_project_#{@project.id}"

  wait_for do
    selenium.is_element_present("submit_project_#{@project.id}")
  end

  fill_in "project[default_tags]", :with => default_tags

  selenium.click "submit_project_#{@project.id}",
    :wait_for => :text,
    :text => "Project saved",
    :timeout => 5

  wait_for :timeout => 5 do
    !selenium.is_element_present("submit_project_#{@project.id}")
  end
end

When /^I edit the project name of "([^"]*)" to "([^"]*)"$/ do |project_current_name, project_new_name|
  @project = @current_user.projects.find_by_name(project_current_name)
  @project.should_not be_nil
  step "I edit the project name to \"#{project_new_name}\""
end

When /^I try to edit the project name of "([^"]*)" to "([^"]*)"$/ do |project_current_name, project_new_name|
  @project = @current_user.projects.find_by_name(project_current_name)
  @project.should_not be_nil
  step "I try to edit the project name to \"#{project_new_name}\""
end

When /^I edit the project name in place to be "([^"]*)"$/ do |new_project_name|
  selenium.click "project_name"
  fill_in "value", :with => new_project_name
  click_button "Ok"
end

When /^I click to edit the project name in place$/ do
  selenium.click "css=div#project_name"
end

Then /^I should be able to change the project name in place$/ do
  #Note that this is not changing the project name
  selenium.wait_for_element "css=div#project_name>form>input"
  selenium.click "css=div#project_name > form > button[type=cancel]"
end

When /^I edit the project settings$/ do
  @project.should_not be_nil

  click_link "link_edit_project_#{@project.id}"
  selenium.wait_for_element("xpath=//div[@id='edit_project_#{@project.id}']/form//button[@id='submit_project_#{@project.id}']")

end

Then /^I should not be able to change the project name in place$/ do
  step "I click to edit the project name in place"
  found = selenium.element? "xpath=//div[@id='project_name']/form/input"
  !found
end

When /^I close the project settings$/ do
  @project.should_not be_nil
  click_link "Cancel"
  wait_for :wait_for => :effects , :javascript_framework => 'jquery' do
    true
  end
end


When /^I edit the project state of "([^"]*)" to "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil

  click_link "link_edit_project_#{project.id}"
  selenium.wait_for_element("xpath=//div[@id='edit_project_#{project.id}']/form//button[@id='submit_project_#{project.id}']")

  choose "project_state_#{state_name}"

  # changed to make sure selenium waits until the saving has a result either
  # positive or negative. Was: :element=>"flash", :text=>"Project saved"
  # we may need to change it back if you really need a positive outcome, i.e.
  # this step needs to fail if the project was not saved successfully
  selenium.click "submit_project_#{project.id}",
    :wait_for => :text,
    :text => /(Project saved|1 error prohibited this project from being saved)/

  wait_for do # wait for the form to go away
    !selenium.is_element_present("submit_project_#{project.id}")
  end
end

When /^I add a note "([^"]*)" to the project$/ do |note_body|
  click_link "Add a note"
  fill_in "note[body]", :with => note_body
  click_button "Add note"
end

When /^I click on the first note icon$/ do
  @project.should_not be_nil
  @note = @project.notes.first # assume first note is also first on screen
  @note.should_not be_nil

  click_link "link_note_#{@note.id}"
end

When /^I cancel adding a note to the project$/ do
  click_link "Add a note"
  fill_in "note[body]", :with => "will not save this"
  click_link "neg_edit_form_note"
end

Then /^the form for adding a note should not be visible$/ do
  wait_for do # wait for the form to go away
    !selenium.is_visible("edit_form_note")
  end
end

Then /^I should go to that note page$/ do
  current_path = URI.parse(current_url).path
  note_path = note_path(@note)
  current_path.should == note_path
end

Then /^I should see one note in the project$/ do
  selenium.wait_for_element("xpath=//div[@class='note_wrapper']")
end

Then /^I should see the bold text "([^\"]*)" in the project description$/ do |bold|
  xpath="//div[@class='project_description']/p/strong"

  response.should have_xpath(xpath)
  bold_text = response.selenium.get_text("xpath=#{xpath}")

  bold_text.should =~ /#{bold}/
end

Then /^I should see the italic text "([^\"]*)" in the project description$/ do |italic|
  xpath="//div[@class='project_description']/p/em"

  response.should have_xpath(xpath)
  italic_text = response.selenium.get_text("xpath=#{xpath}")

  italic_text.should =~ /#{italic}/
end

Then /^the project title should be "(.*)"$/ do |title|
  wait_for :timeout => 2 do
    selenium.get_text("css=h2#project_name_container div#project_name") == title
  end
end

Then /^I should see the project name is "([^"]*)"$/ do |project_name|
  step "the project title should be \"#{project_name}\""
end
