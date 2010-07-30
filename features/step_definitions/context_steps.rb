Given /^I have no contexts$/ do
  # should probably not be needed as you use this given at the start of a scenario
  Context.delete_all
end

Given /^there exists a context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  user = User.find_by_login(login)
  user.should_not be_nil
  @context = user.contexts.create!(:name => context_name)
end

Given /^I have a context called "([^\"]*)"$/ do |context_name|
  Given "there exists a context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have the following contexts:$/ do |table|
  table.hashes.each do |context|
    Given 'I have a context called "'+context[:context]+'"'
  end
end

Given /^I have a context "([^\"]*)" with (.*) actions$/ do |context_name, number_of_actions|
  context = @current_user.contexts.create!(:name => context_name)
  1.upto number_of_actions.to_i do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
  end
end

Given /^I have the following contexts$/ do |table|
  Context.delete_all
  table.hashes.each do |hash|
    context = Factory(:context, hash)
  end
end

When /^I visit the context page for "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  visit "/contexts/#{context.id}" 
end

When /^I edit the context name in place to be "([^\"]*)"$/ do |new_context_name|
  selenium.click "context_name"
  fill_in "value", :with => "OutAndAbout"
  click_button "OK"
end

When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  click_link "delete_context_#{context.id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the context '#{context_name}'? Be aware that this will also delete all actions in this context!"
  wait_for do
    !selenium.is_element_present("delete_context_#{context.id}")
  end
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  click_link "edit_context_#{@context.id}"

  wait_for do
    selenium.is_element_present("submit_context_#{@context.id}")
  end

  fill_in "context_name", :with => new_name

  selenium.click "submit_context_#{@context.id}",
    :wait_for => :text,
    :element => "flash",
    :text => "Context saved"
  
  wait_for do
    selenium.is_element_present("edit_context_#{@context.id}")
  end
end

When /^I add a new context "([^"]*)"$/ do |context_name|
  fill_in "context[name]", :with => context_name
  submit_new_context_form
end

When /^I add a new hidden context "([^"]*)"$/ do |context_name|
  fill_in "context[name]", :with => context_name
  check "context_hide"
  submit_new_context_form
end

Then /^I should see the context name is "([^\"]*)"$/ do |context_name|
  Then "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" is present$/ do |context_name|
  Then "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" is not present$/ do |context_name|
  Then "I should not see \"#{context_name} (\""
end

Then /^I should see the context "([^"]*)" under "([^"]*)"$/ do |context_name, state|
  context = Context.find_by_name(context_name)
  response.should have_xpath("//div[@id='list-contexts-#{state}']//div[@id='context_#{context.id}']")
end
