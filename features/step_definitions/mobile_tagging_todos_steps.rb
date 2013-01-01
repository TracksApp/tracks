When /^I follow the tag "(.*?)"$/ do |tag_name|
  # there could be more than one tag on the page, so use the first
  all(:xpath, "//span[@class='tag #{tag_name}']/a")[0].click
end