Given /^I have a context called "([^\"]*)"$/ do |context_name|
  @context = @current_user.contexts.create!(:name => context_name)
end

When /^I visits the context page for "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  visit "/contexts/#{context.id}" 
end

When /^I edit the context name in place to be "([^\"]*)"$/ do |new_context_name|
  selenium.click "context_name"
  fill_in "value", :with => "OutAndAbout"
  click_button "OK"
end

Then /^I should see the context name is "([^\"]*)"$/ do |context_name|
  Then "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" is present$/ do |context_name|
  Then "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" is not present$/ do |context_name|
  Then "I should not see \"#{context_name}\""
end

Given /^I have a context "([^\"]*)" with (.*) actions$/ do |context_name, number_of_actions|
  context = @current_user.contexts.create!(:name => context_name)
  1.upto number_of_actions.to_i do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
  end
end

When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  click_link "delete_context_#{context.id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the context '#{context_name}'?"
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  click_link "edit_context_#{@context.id}"
  fill_in "context_name", :with => new_name
  click_button "submit_context_#{@context.id}"
end
