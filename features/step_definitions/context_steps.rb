Given /^I have no contexts$/ do
  # should probably not be needed as you use this given at the start of a scenario
  Context.delete_all
end

Given /^there exists an active context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  user = User.find_by_login(login)
  user.should_not be_nil
  @context = user.contexts.create!(:name => context_name, :hide => false)
end

Given /^there exists a context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  Given "there exists an active context called \"#{context_name}\" for user \"#{login}\""
end

Given /^there exists a hidden context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  user = User.find_by_login(login)
  user.should_not be_nil
  @context = user.contexts.create!(:name => context_name, :hide => true)
end

Given /^I have a context called "([^\"]*)"$/ do |context_name|
  Given "there exists an active context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have an active context called "([^\"]*)"$/ do |context_name|
  Given "there exists an active context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have a hidden context called "([^\"]*)"$/ do |context_name|
  Given "there exists a hidden context called \"#{context_name}\" for user \"#{@current_user.login}\""
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

# TODO: refactor this to paths.rb
When /^I visit the context page for "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  visit "/contexts/#{context.id}" 
end

When /^I edit the context name in place to be "([^\"]*)"$/ do |new_context_name|
  selenium.click "context_name"
  fill_in "value", :with => new_context_name
  click_button "Ok"
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