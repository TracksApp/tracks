Given /^I have no projects$/ do
  Project.delete_all
end

Given /^I have an outdated project "([^"]*)" with (\d+) todos$/ do |project_name, num_todos|
  step "I have a project \"#{project_name}\" with #{num_todos} todos"
  @project = @current_user.projects.where(:name => project_name).first
  @project.last_reviewed = UserTime.new(@current_user).time - @current_user.prefs.review_period.days-1
  @project.save
end

Given /^I have a project "([^"]*)" with (\d+) deferred actions$/ do |name, deferred|
  step "I have a project \"#{name}\" with #{deferred} deferred todos"
end

Given /^I have a project "([^"]*)" with (\d+) active actions and (\d+) deferred actions$/ do |name, active_count, deferred_count|
  step "I have a project \"#{name}\" with #{active_count} active todos"
  step "I have a project \"#{name}\" with #{deferred_count} deferred todos"
end

Given /^I have a project "([^"]*)" with (\d+) (todo|active todo|deferred todo)s prefixed by "([^\"]*)"$/ do |project_name, num_todos, state, prefix|
  @context = @current_user.contexts.where(:name => "Context A").first_or_create
  @project = @current_user.projects.where(:name => project_name).first_or_create
  # acts_as_list adds at top by default, but that is counter-intuitive when reading scenario's, so reverse this
  @project.move_to_bottom

  @todos=[]
  1.upto num_todos.to_i do |i|
    todo = @current_user.todos.create!(
      :project_id => @project.id,
      :context_id => @context.id,
      :description => "#{prefix}#{state} #{i}")
    todo.show_from = Time.zone.now + 1.week if state=="deferred todo"
    todo.save!
    @todos << todo
  end
end

Given /^I have a project "([^"]*)" with (\d+) (todos|active todos|deferred todos)$/ do |project_name, num_todos, state|
  step "I have a project \"#{project_name}\" with #{num_todos} #{state} prefixed by \"\""
end

Given /^there exists a project (?:|called )"([^"]*)" for user "([^"]*)"$/ do |project_name, user_name|
  user = User.where(:login => user_name).first
  expect(user).to_not be_nil
  @project = user.projects.create!(:name => project_name)
  # acts_as_list adds at top by default, but that is counter-intuitive when reading scenario's, so reverse this
  @project.move_to_bottom
end

Given /^I have a project (?:|called )"([^"]*)"$/ do |project_name|
  @project = @current_user.projects.create!(:name => project_name)
end

Given /^I have a project "([^"]*)" with a default context of "([^"]*)"$/ do |project_name, context_name|
  step "I have a project \"#{project_name}\""
  context = @current_user.contexts.create!(:name => context_name)
  @project.default_context = context
  @project.save!
end

Given /^I have the following projects:$/ do |table|
  table.hashes.each do |project|
    step "I have a project called \"#{project[:project_name]}\""
    # acts_as_list puts the last added project at the top, but we want it
    # at the bottom to be consistent with the table in the scenario
    @project.move_to_bottom
    @project.save!
  end
end

Given /^I have a (completed|hidden) project called "([^"]*)"$/ do |state, project_name|
  step "I have a project called \"#{project_name}\""
  @project.send(state=="completed" ? "complete!" : "hide!")
  @project.reload
  expect(@project.send(state=="completed" ? "completed?" : "hidden?")).to be true
end

Given /^I have (\d+) completed projects$/ do |number_of_projects|
  1.upto number_of_projects.to_i do |i|
    step "I have a completed project called \"Project #{i}\""
  end
end

Given /^I have one project "([^\"]*)" with no notes$/ do |project_name|
  step "I have a project called \"#{project_name}\""
end

Given /^I have two projects with one note each$/ do
  step "I have a project \"project A\""
  @project.notes.create!(:user_id => @current_user.id, :body => 'note for project A')
  step "I have a project \"project B\""
  @project.notes.create!(:user_id => @current_user.id, :body => 'note for project B')
end

Given /^I have a project "([^\"]*)" with (.*) notes?$/ do |project_name, num|
  project = @current_user.projects.create!(:name => project_name)
  1.upto num.to_i do |i|
    project.notes.create!(:user_id => @current_user.id, :body => "A note #{i}. This is the very long body of note #{i} where you should not see the last part of the note after 50 characters")
  end
end

Given /^the default tags for "(.*?)" are "(.*?)"$/ do |project_name, default_tags|
  project = @current_user.projects.where(:name => project_name).first
  expect(project).to_not be_nil
  
  project.default_tags = default_tags
  project.save!
end

When /^I open the project edit form$/ do
  click_link "link_edit_project_#{@project.id}"
  expect(page).to have_css("button#submit_project_#{@project.id}", :visible => true)
end

When /^I cancel the project edit form$/ do
  click_link "cancel_project_#{@project.id}"
  expect(page).to_not have_css("submit_project_#{@project.id}")
  wait_for_animations_to_end
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
    within "form.edit-project-form" do
      fill_in "project[name]", :with => new_title
    end
  end
end

When /^I edit the default context to "([^"]*)"$/ do |default_context|
  edit_project(@project) do
    fill_in "project[default_context_name]", :with => default_context
  end
end

When /^I edit the project name of "([^"]*)" to "([^"]*)"$/ do |project_current_name, project_new_name|
  @project = @current_user.projects.where(:name => project_current_name).first
  expect(@project).to_not be_nil
  step "I edit the project name to \"#{project_new_name}\""
end

When /^I try to edit the project name of "([^"]*)" to "([^"]*)"$/ do |project_current_name, project_new_name|
  @project = @current_user.projects.where(:name => project_current_name).first
  expect(@project).to_not be_nil
  step "I try to edit the project name to \"#{project_new_name}\""
end

When /^I edit the project name in place to be "([^"]*)"$/ do |new_project_name|
  page.find("span#project_name").click
  fill_in "value", :with => new_project_name
  click_button "Ok"
end

When /^I click to edit the project name in place$/ do
  page.find("span#project_name").click
end

When /^I edit the project settings$/ do
  expect(@project).to_not be_nil

  click_link "link_edit_project_#{@project.id}"
  expect(page).to have_xpath("//div[@id='edit_project_#{@project.id}']/form//button[@id='submit_project_#{@project.id}']")
end

When /^I close the project settings$/ do
  expect(@project).to_not be_nil
  click_link "Cancel"
  wait_for_ajax
  wait_for_animations_to_end
end

When /^I edit the project state of "([^"]*)" to "([^"]*)"$/ do |project_name, state_name|
  project = @current_user.projects.where(:name => project_name).first
  expect(project).to_not be_nil

  edit_project_settings(project) do
    choose "project_state_#{state_name}"
  end
end

When /^I edit project "([^"]*)" and mark the project as reviewed$/ do |project_name|
  project = @current_user.projects.where(:name => project_name).first
  expect(project).to_not be_nil
  
  open_project_edit_form(project)
  click_link "reviewed_project_#{project.id}"
end

When /^I edit project settings and mark the project as reviewed$/ do
  open_project_edit_form(@project)
  click_link "reviewed_project_#{@project.id}"
end

When /^I add a note "([^"]*)" to the project$/ do |note_body|
  submit_button = "div.widgets button#submit_note"

  click_link "Add a note"
  expect(page).to have_css submit_button
  fill_in "note[body]", :with => note_body
  
  elem = find(submit_button)
  expect(elem).to_not be_nil
  elem.click

  expect(page).to_not have_css(submit_button, visible: true)
end

When /^I click on the first note icon$/ do
  expect(@project).to_not be_nil
  @note = @project.notes.first # assume first note is also first on screen
  expect(@note).to_not be_nil

  click_link "link_note_#{@note.id}"
end

When /^I cancel adding a note to the project$/ do
  click_link "Add a note"
  fill_in "note[body]", :with => "will not save this"
  click_link "neg_edit_form_note"
end

Then /^I edit the default tags to "([^"]*)"$/ do |default_tags|
  edit_project(@project) do
    fill_in "project[default_tags]", :with => default_tags
  end
end

Then /^I should be able to change the project name in place$/ do
  # Note that this is not changing the project name
  expect(page).to have_css("span#project_name>form>input")
  page.find("span#project_name > form > button[type=cancel]").click
  expect(page).to_not have_css("span#project_name>form>input")
end

Then /^I should not be able to change the project name in place$/ do
  step "I click to edit the project name in place"
  expect(page).to_not have_xpath("//span[@id='project_name']/form/input")
end

Then /^the form for adding a note should not be visible$/ do
  expect(page).to_not have_css("edit_form_note")
end

Then /^I should go to that note page$/ do
  current_path = URI.parse(current_url).path
  note_path = note_path(@note)
  expect(current_path).to eq(note_path)
end

Then /^I should see one note in the project$/ do
  expect(page).to have_xpath("//div[@class='note_wrapper']")
end

Then /^I should see the bold text "([^\"]*)" in the project description$/ do |text_in_bold|
  xpath="//div[@class='project_description']/p/strong"

  expect(page).to have_xpath(xpath)
  bold_text = page.find(:xpath, xpath).text
  expect(bold_text).to match(/#{text_in_bold}/)
end

Then /^I should see the italic text "([^\"]*)" in the project description$/ do |text_in_italic|
  xpath="//div[@class='project_description']/p/em"

  expect(page).to have_xpath(xpath)
  italic_text = page.find(:xpath, xpath).text
  expect(italic_text).to match(/#{text_in_italic}/)
end

Then /^the project title should be "(.*)"$/ do |title|
  expect(page).to have_css("h2#project_name_container span#project_name", text: title, exact: true)
end

Then /^I should see the project name is "([^"]*)"$/ do |project_name|
  step "the project title should be \"#{project_name}\""
end

Then /^I should (see|not see) the default project settings$/ do |visible|
  default_settings = "This project is active with no default context and with no default tags"

  expect(page).to have_css("div.project_settings")
  elem = page.find("div.project_settings")
  
  if visible == "see"
    expect(elem).to be_visible
    expect(elem.text).to match(/#{default_settings}/)
  else
    expect(elem).to_not be_visible
  end
end

Then /^I should have a project called "([^"]*)"$/ do |project_name|
  project = @current_user.projects.where(:name => project_name).first
  expect(project).to_not be_nil
end

Then /^I should have (\d+) todos? in project "([^"]*)"$/ do |todo_count, project_name|
  project = @current_user.projects.where(:name => project_name).first
  expect(project).to_not be_nil
  expect(project.todos.count).to eq(todo_count.to_i)
end
