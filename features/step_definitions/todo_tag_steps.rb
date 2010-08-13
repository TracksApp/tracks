When /^I visit the tag page for "([^"]*)"$/ do |tag_name|
  visit "/todos/tag/#{tag_name}"
end
