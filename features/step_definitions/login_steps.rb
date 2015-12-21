Given /^I have logged in as "(.*)" with password "(.*)"$/ do |username, password|
  user = User.where(:login => username).first
  request_signin_as(user)
  @current_user = user
end

When /^I submit the login form as user "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'Login', :with => username
  fill_in 'Password', :with => password
  uncheck "Stay logged in"
  click_button "Sign in"
end

When /^my session expires$/ do
  # use expire_session to force expiry of session
  js = '$.ajax({type: "GET", url: "/login/expire_session", dataType: "script", async: false});'
  page.execute_script(js);

  # force check of expiry bypassing timeout
  js = '$.ajax({type: "GET", url: "/login/check_expiry", dataType: "script", async: false});'
  page.execute_script(js);
  sleep 1
end

When /^I log out of Tracks$/ do
  step "I go to the logout page"
end
