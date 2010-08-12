Given /^I have a project "([^\"]*)" with (.*) todos$/ do |project_name, num_todos|
  context = @current_user.contexts.create!(:name => "Context A")
  project = @current_user.projects.create!(:name => project_name)
  1.upto num_todos.to_i do |i|
    @current_user.todos.create!(
      :project_id => project.id,
      :context_id => context.id,
      :description => "Todo #{i}")
  end
end

Given /^there exists a project "([^\"]*)" for user "([^\"]*)"$/ do |project_name, user_name|
  user = User.find_by_login(user_name)
  user.should_not be_nil
  @project = user.projects.create!(:name => project_name)
end

Given /^there exists a project called "([^"]*)" for user "([^"]*)"$/ do |project_name, login|
  # TODO: regexp change to integrate this with the previous since only 'called' is different
  Given "there exists a project \"#{project_name}\" for user \"#{login}\""
end

Given /^I have a project called "([^"]*)"$/ do |project_name|
  Given "there exists a project \"#{project_name}\" for user \"#{@current_user.login}\""
end

When /^I visit the "([^\"]*)" project$/ do |project_name|
  @project = Project.find_by_name(project_name)
  @project.should_not be_nil
  visit project_path(@project)
end

When /^I visit the project page for "([^"]*)"$/ do |project_name|
  When "I visit the \"#{project_name}\" project"
end

When /^I edit the project description to "([^\"]*)"$/ do |new_description|
  click_link "link_edit_project_#{@project.id}"
  fill_in "project[description]", :with => new_description
  click_button "submit_project_#{@project.id}"
end

When /^I edit the project name to "([^\"]*)"$/ do |new_title|
  click_link "link_edit_project_#{@project.id}"
  fill_in "project[name]", :with => new_title

  # changed to make sure selenium waits until the saving has a result either
  # positive or negative. Was: :element=>"flash", :text=>"Project saved"
  # we may need to change it back if you really need a positive outcome, i.e.
  # this step needs to fail if the project was not saved succesfully
  selenium.click "submit_project_#{@project.id}",
    :wait_for => :text,
    :text => /(Project saved|1 error prohibited this project from being saved)/
end

When /^I edit the project name of "([^"]*)" to "([^"]*)"$/ do |project_current_name, project_new_name|
  @project = @current_user.projects.find_by_name(project_current_name)
  @project.should_not be_nil
  When "I edit the project name to \"#{project_new_name}\""
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
  selenium.get_text("css=h2#project_name").should == title
end