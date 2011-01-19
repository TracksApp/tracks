Then /^I should see a message that you need a context to get feeds for contexts$/ do
  Then "I should see \"There needs to be at least one context before you can request a feed\""
end

Then /^I should see a message that you need a project to get feeds for projects$/ do
  Then "I should see \"There needs to be at least one project before you can request a feed\""
end

Then /^I should see feeds for projects$/ do
  within 'select[id="feed-projects"]' do |scope|
    scope.should have_selector("option[value=\"#{@current_user.projects.first.id}\"]")
  end
end

Then /^I should see feeds for contexts$/ do
  within 'select[id="feed-contexts"]' do |scope|
    scope.should have_selector("option[value=\"#{@current_user.contexts.first.id}\"]")
  end
end

Then /^I should see "([^"]*)" as the selected project$/ do |project_name|
  within 'select[id="feed-projects"]' do |scope|
    scope.should have_selector("option[selected=\"selected\"]", :content => project_name)
  end
end

Then /^I should see "([^"]*)" as the selected context$/ do |context_name|
  within 'select[id="feed-contexts"]' do |scope|
    scope.should have_selector("option[selected=\"selected\"]", :content => context_name)
  end
end

Then /^I should see feeds for "([^"]*)" in list of "([^"]*)"$/ do |name, list_type|
  selenium.wait_for :wait_for => :ajax, :javascript_framework => :jquery
  xpath= "//div[@id='feeds-for-#{list_type}']//strong"
  name.should == response.selenium.get_text("xpath=#{xpath}")
end
