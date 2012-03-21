Given /this is a pending scenario/ do
  pending
end

Given /^I set the locale to "([^"]*)"$/ do |locale|
  @locale = locale
end

Given /^I am working on the mobile interface$/ do
  @mobile_interface = true
end

Then /the badge should show (.*)/ do |number|
  badge = find("span#badge_count").text.to_i
  badge.should == number.to_i
end

Then /^I should see an error flash message saying "([^"]*)"$/ do |message|
  xpath = "//div[@id='message_holder']/h4[@id='flash']"
  page.should have_xpath(xpath, :visible => true)
  
  text = page.find(:xpath, xpath).text
  text.should == message
end

Then /^I should see "([^"]*)" $/ do |text|
  step "I should see \"#{text}\""
end

Then /^I should save and open the page$/ do
  save_and_open_page
end
