Given /^the following user records?$/ do |table|
  User.delete_all
  table.hashes.each do |hash|
    user = Factory(:user, hash)
    user.create_preference
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
