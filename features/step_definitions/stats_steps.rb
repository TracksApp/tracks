When /^I click on the chart for actions done in the last 12 months$/ do
  # cannot really click the chart which is a swf
  visit stats_path + "/actions_done_last_years"
end

Then /^I should see a chart$/ do
  expect(page).to have_css("div.open-flash-chart")
end

When /^I click on the chart for running time of all incomplete actions$/ do
  # cannot really click the chart which is a swf
  visit stats_path + "/show_selected_actions_from_chart/art?index=0"
end

When /^I click on the chart for running time of all incomplete visible actions$/ do
  # cannot really click the chart which is a swf
  visit stats_path + "/show_selected_actions_from_chart/avrt?index=0"
end
