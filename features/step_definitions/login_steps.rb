Given /^I have logged in as "(.*)" with password "(.*)"$/ do |username, password|
  step "I go to the login page"
  fill_in "Login", :with => username
  fill_in "Password", :with => password
  uncheck "Stay logged in:"
  click_button "Sign in »"
  
  logout_regexp = @mobile_interface ? "Logout" : "Logout \(#{username}\)"
  page.should have_content(logout_regexp)
  @current_user = User.find_by_login(username)
end

When /^I submit the login form as user "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'Login', :with => username
  fill_in 'Password', :with => password
  uncheck "Stay logged in:"
  click_button "Sign in »"
end

When /^my session expires$/ do
  # use expire_session to force expiry of session
  js = '$.ajax({type: "GET", url: "/login/expire_session", dataType: "script", async: false});'
  page.execute_script(js);

  # force check of expiry bypassing timeout
  js = '$.ajax({type: "GET", url: "/login/check_expiry", dataType: "script", async: false});'
  page.execute_script(js);
end

When /^I log out of Tracks$/ do
  step "I go to the logout page"
end
