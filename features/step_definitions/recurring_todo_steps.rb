When /^I select "([^\"]*)" recurrence pattern$/ do |recurrence_period|
  selenium.click("recurring_todo_recurring_period_#{recurrence_period.downcase}")
end

Then /^I should see the form for "([^\"]*)" recurrence pattern$/ do |recurrence_period|
  selenium.is_visible("recurring_#{recurrence_period.downcase}")
end
