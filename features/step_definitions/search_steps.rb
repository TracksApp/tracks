When /^I search for "([^"]*)"$/ do |search_arg|
  fill_in "search", :with => search_arg
  click_button "Search"
end