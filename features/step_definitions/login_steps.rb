Given /^I have logged in as "(.*)" with password "(.*)"$/ do |username, password|
  When "I go to the login page"
  fill_in "Login", :with => username
  fill_in "Password", :with => password
  uncheck "Stay logged in:"
  click_button
  if response.respond_to? :selenium
    selenium.wait_for_page_to_load(5000)
  end
  logout_regexp = @mobile_interface ? "Logout" : "Logout \(#{username}\)"
  response.should contain(logout_regexp)
  @current_user = User.find_by_login(username)
end

When /^I submit the login form as user "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  fill_in 'Login', :with => username
  fill_in 'Password', :with => password
  uncheck "Stay logged in:"
  click_button
end

When /^my session expires$/ do
  selenium.wait_for_page_to_load(5000)

  # use expire_session to force expiry of session
  js = '$.ajax({type: "GET", url: "/login/expire_session", dataType: "script", async: false});'
  selenium.run_script(js);
  
  # force check of expiry bypassing timeout
  js = '$.ajax({type: "GET", url: "/login/check_expiry", dataType: "script", async: false});'
  selenium.run_script(js);

  sleep(2)
end
