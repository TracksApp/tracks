Given /^I am logged in$/ do
  @current_user = User.create!(:login => "testuser", :password => "secret", :password_confirmation => "secret")
  @current_user.create_preference
  visit login_path
  fill_in "login", :with => "testuser"
  fill_in "password", :with => "secret"
  click_button "Sign in"
  response.body.should =~ /Login successful/m
end
