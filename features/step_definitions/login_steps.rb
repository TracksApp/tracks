Given /^I am logged in$/ do
  @current_user = User.create!(:login => "testuser", :password => "secret", :password_confirmation => "secret")
  @current_user.create_preference
  visit login_path
  fill_in "login", :with => "testuser"
  fill_in "password", :with => "secret"
  click_button "Sign in"
  response.body.should =~ /Login successful/m
end

Given /^public signups are turned (.*)$/ do |state|
  case state 
  when 'on'
    SITE_CONFIG['open_signups'] = true
  when 'off'
    SITE_CONFIG['open_signups'] = false
  else
    raise "public signups should be either 'on' or 'off'"
  end
end

When "I successfully submit the signup form" do
  fill_in 'Desired login', :with => 'reinier'
  fill_in 'Choose password', :with => 'abracadabra'
  fill_in 'Confirm password', :with => 'abracadabra'
  click_button
end

When "I submit signup form with dissimmilar password and confirmation" do
  fill_in 'Desired login', :with => 'reinier'
  fill_in 'Choose password', :with => 'abracadabra'
  fill_in 'Confirm password', :with => 'somethingelse'
  click_button
end

Then "I should be an admin" do
  # just check on the presence of the menu item for managing users
  Then "I should see \"Manage users\""
end

When "I submit the login form as an admin user with an incorrect password" do
  Given "an admin user exists"
  fill_in 'Login', :with => 'admin'
  fill_in 'Password', :with => 'incorrectpass'
  click_button
end

When "I successfully submit the login form as an admin user" do
  Given "an admin user exists"
  fill_in 'Login', :with => 'admin'
  fill_in 'Password', :with => 'abracadabra'
  click_button
end

When "Reinier visits the site" do
  visits '/'
end

Then "Reinier should see the tasks listing page" do
  response.should have_tag('title', /list tasks/i)
end

Then "Reinier should see the login page again" do
  response.should have_tag('title', /login/i)
end
  
Then "Reinier should see the message Login unsuccessful" do
  should_see 'Login unsuccessful'
end