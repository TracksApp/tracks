When /^I edit my last name to "([^"]*)"$/ do |last_name|
  fill_in "user[last_name]", :with => last_name
  click_button "prefs_submit"
end

When /^I set the password and confirmation to "([^"]*)"$/ do |new_password|
  step "I set the password to \"#{new_password}\" and confirmation to \"#{new_password}\""
end

When /^I set the password to "([^"]*)" and confirmation to "([^"]*)"$/ do |new_password, new_password_confirmation|
  fill_in "user[password]", :with => new_password
  fill_in "user[password_confirmation]", :with => new_password_confirmation
  click_button "prefs_submit"
end

