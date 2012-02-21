Then /^I should see a message that you need a context to get feeds for contexts$/ do
  step "I should see \"There needs to be at least one context before you can request a feed\""
end

Then /^I should see a message that you need a project to get feeds for projects$/ do
  step "I should see \"There needs to be at least one project before you can request a feed\""
end

Then /^I should see feeds for projects$/ do
  page.should have_css("select#feed-projects option[value='#{@current_user.projects.first.id}']")
end

Then /^I should see feeds for contexts$/ do
  page.should have_css("select#feed-contexts option[value='#{@current_user.contexts.first.id}']")
end

Then /^I should see "([^"]*)" as the selected project$/ do |project_name|
  page.should have_css 'select#feed-projects option[selected="selected"]'
end

Then /^I should see "([^"]*)" as the selected context$/ do |context_name|
  page.should have_css 'select#feed-contexts option[selected="selected"]'
end

Then /^I should see feeds for "([^"]*)" in list of "([^"]*)"$/ do |name, list_type|
  wait_for_ajax
  xpath= "//div[@id='feeds-for-#{list_type}']//strong"
  name.should == find(:xpath, xpath).text
end
