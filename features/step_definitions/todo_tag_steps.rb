Then /^I should not see empty message for todos of tag$/ do
  find("div#no_todos_in_view").should_not be_visible
end

Then /^I should see empty message for todos of tag$/ do
  find("div#no_todos_in_view").should be_visible
end

Then /^I should not see empty message for completed todos of tag$/ do
  find("div#empty-d").should_not be_visible
end

Then /^I should see empty message for completed todos of tag$/ do
  find("div#empty-d").should be_visible
end

Then /^I should not see empty message for deferred todos of tag$/ do
  find("div#tickler-empty-nd").should_not be_visible
end

Then /^I should see empty message for deferred todos of tag$/ do
  find("div#tickler-empty-nd").should be_visible
end
