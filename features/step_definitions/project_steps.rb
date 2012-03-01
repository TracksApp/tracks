Given /^I have an outdated project "([^"]*)" with (\d+) todos$/ do |project_name, num_todos|
  step "I have a project \"#{project_name}\" with #{num_todos} todos"
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
  page.should have_css("button#submit_project_#{@project.id}", :visible => true)
end

When /^I cancel the project edit form$/ do
  click_link "cancel_project_#{@project.id}"

  wait_until do
    !page.has_css?("submit_project_#{@project.id}")
  end
end

When /^I edit the project description to "([^\"]*)"$/ do |new_description|
  edit_project(@project) do
    fill_in "project[description]", :with => new_description
  end
end

When /^I edit the project name to "([^\"]*)"$/ do |new_title|
  edit_project(@project) do
    fill_in "project[name]", :with => new_title
  end
end

When /^I try to edit the project name to "([^\"]*)"$/ do |new_title|
  edit_project_no_wait(@project) do
    fill_in "project[name]", :with => new_title
  end
end

When /^I edit the default context to "([^"]*)"$/ do |default_context|
  edit_project(@project) do
    fill_in "project[default_context_name]", :with => default_context
  end
end

Then /^I should (see|not see) empty message for (todos|deferred todos|completed todos) of project/ do |visible, state|
  case state
  when "todos"
    css = "div#p#{@project.id}empty-nd"
  when "deferred todos"
    css = "div#tickler-empty-nd"
  when "completed todos"
    css = "div#empty-d"
  else
    css = "wrong state"
  end
  
  elem = find(css)
  elem.nil?.should be_false
  elem.visible?.should(visible=="see" ? be_true : be_false)
end

Then /^I edit the default tags to "([^"]*)"$/ do |default_tags|
  edit_project(@project) do
    fill_in "project[default_tags]", :with => default_tags
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
  page.find("div#project_name").click
  fill_in "value", :with => new_project_name
  click_button "Ok"
end

When /^I click to edit the project name in place$/ do
  page.find("div#project_name").click
end

Then /^I should be able to change the project name in place$/ do
  #Note that this is not changing the project name
  wait_until do
    page.has_css? "div#project_name>form>input"
  end
  page.find("div#project_name > form > button[type=cancel]").click
end

When /^I edit the project settings$/ do
  @project.should_not be_nil

  click_link "link_edit_project_#{@project.id}"
  page.has_xpath?("//div[@id='edit_project_#{@project.id}']/form//button[@id='submit_project_#{@project.id}']").should be_true
end

Then /^I should not be able to change the project name in place$/ do
  step "I click to edit the project name in place"
  page.has_xpath?("//div[@id='project_name']/form/input").should be_false
end

When /^I close the project settings$/ do
  @project.should_not be_nil
  click_link "Cancel"
  wait_for_ajax
  wait_for_animations_to_end
end


When /^I edit the project state of "([^"]*)" to "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.find_by_name(project_name)
  project.should_not be_nil

  edit_project_settings(project) do
    choose "project_state_#{state_name}"
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
  page.should_not have_css("edit_form_note")
end

Then /^I should go to that note page$/ do
  current_path = URI.parse(current_url).path
  note_path = note_path(@note)
  current_path.should == note_path
end

Then /^I should see one note in the project$/ do
  page.should have_xpath("//div[@class='note_wrapper']")
end

Then /^I should see the bold text "([^\"]*)" in the project description$/ do |text_in_bold|
  xpath="//div[@class='project_description']/p/strong"

  page.should have_xpath(xpath)
  bold_text = page.find(:xpath, xpath).text

  bold_text.should =~ /#{text_in_bold}/
end

Then /^I should see the italic text "([^\"]*)" in the project description$/ do |text_in_italic|
  xpath="//div[@class='project_description']/p/em"

  page.should have_xpath(xpath)
  italic_text = page.find(:xpath, xpath).text

  italic_text.should =~ /#{text_in_italic}/
end

Then /^the project title should be "(.*)"$/ do |title|
  wait_until do
    page.find("h2#project_name_container div#project_name").text == title
  end
end

Then /^I should see the project name is "([^"]*)"$/ do |project_name|
  step "the project title should be \"#{project_name}\""
end

Then /^I should (see|not see) the default project settings$/ do |visible|
  default_settings = "This project is active with no default context and with no default tags"
  if visible == "see"
    elem = page.find("div.project_settings")
    elem.visible?.should be_true
    elem.text.should =~ /#{default_settings}/
  else
    elem = page.find("div.project_settings")
    elem.visible?.should be_false
  end
end