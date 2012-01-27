Then /^I should be redirected to (.+?)$/ do |page_name|
  Then "I should be on #{page_name}"
end