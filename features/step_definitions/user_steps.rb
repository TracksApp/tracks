Given /^the following user records?$/ do |table|
  User.delete_all
  table.hashes.each do |hash|
    user = Factory(:user, hash)
    user.create_preference({:locale => 'en'})
  end
end

Given "no users exists" do
  User.delete_all
end

When /^I delete the user "([^\"]*)"$/ do |username|
  # click "//tr[@id='user-3']//img"
  # assert_confirmation "Warning: this will delete user 'john', all their actions, contexts, project and notes. Are you sure that you want to continue?"
  user = User.find_by_login(username)
  user.should_not be_nil

  selenium.click "xpath=//tr[@id='user-#{user.id}']//img"
  selenium.get_confirmation.should == "Warning: this will delete user '#{user.login}', all their actions, contexts, project and notes. Are you sure that you want to continue?"
  wait_for do
    !selenium.is_element_present("//tr[@id='user-#{user.id}']//img")
  end

end

Then /^I should see that a user named "([^\"]*)" is not present$/ do |username|
  Then "I should not see \"#{username} (\""
end

Then "I should be an admin" do
  # just check on the presence of the menu item for managing users
  Then "I should see \"Manage users\""
end

When /^I change my password to "([^"]*)"$/ do |password|
  Then 'I should be on the change password page'
  %w{new confirm}.each { |name| fill_in name + ' password', :with => password }
  click_button
end
