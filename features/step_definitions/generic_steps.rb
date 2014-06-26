Given /this is a pending scenario/ do
  pending
end

Given(/^I set the locale to "([^"]*)"$/) do |locale|
  @locale = locale
end

Given /^I am working on the mobile interface$/ do
  @mobile_interface = true
end

Given(/^I have selected the view for group by (project|context)$/) do |grouping|
  @group_view_by = grouping 
end

Then /the badge should show (.*)/ do |number|
  badge = find("span#badge_count").text.to_i
  expect(badge).to eq(number.to_i)
end

Then(/^I should see an error flash message saying "([^"]*)"$/) do |message|
  xpath = "//div[@id='message_holder']/h4[@id='flash']"
  expect(page).to have_xpath(xpath, :visible => true)
  
  text = page.find(:xpath, xpath).text
  expect(text).to eq(message)
end

Then /^I should see "([^"]*)" $/ do |text|
  step "I should see \"#{text}\""
end

Then /^I should save and open the page$/ do
  save_and_open_page
end
