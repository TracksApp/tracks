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

When /^I submit the signup form with username "([^\"]*)", password "([^\"]*)" and confirm with "([^\"]*)"$/ do |username, password, confirm|
  fill_in 'Desired login', :with => username
  fill_in 'Choose password', :with => password
  fill_in 'Confirm password', :with => confirm
  click_button "Signup"
end