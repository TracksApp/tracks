Given /^the following user records?$/ do |table|
  table.hashes.each do |hash|
    user = Factory(:user, hash)
    user.create_preference
  end
end

Given "no users exists" do
  User.delete_all
end

Then "I should be an admin" do
  # just check on the presence of the menu item for managing users
  Then "I should see \"Manage users\""
end