Then /^I should not see empty message for todos of tag$/ do
  page.should_not have_css("div#no_todos_in_view", :visible => true)
end

Then /^I should see empty message for todos of tag$/ do
  page.should have_css("div#no_todos_in_view", :visible => true)
end

Then /^I should not see empty message for completed todos of tag$/ do
  page.should_not have_css("div#empty-d", :visible=>true)
end

Then /^I should see empty message for completed todos of tag$/ do
  page.should have_css("div#empty-d", :visible=>true)
end

Then /^I should not see empty message for deferred todos of tag$/ do
  page.should_not have_css("div#tickler-empty-nd", :visible=>true)
end

Then /^I should see empty message for deferred todos of tag$/ do
  page.should have_css("div#tickler-empty-nd", :visible=>true)
end
