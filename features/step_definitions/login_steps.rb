Given /^I have logged in as "(.*)" with password "(.*)"$/ do |username, password|
  visit login_path
  fill_in "login", :with => username
  fill_in "password", :with => password
  click_button "Sign in"
  response.body.should =~ /Login successful/m
  @current_user = User.find_by_login(username)
end

When /^I submit the login form as user "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'Login', :with => username
  fill_in 'Password', :with => password
  click_button
end