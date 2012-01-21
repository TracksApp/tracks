Then /^I see the project "([^"]*)" in the "([^"]*)" list$/ do |arg1, arg2|
  ## does not check whether the project is actually stalled
  ## need to check whether arg1 is in the right category for arg2
  response.body.should contain(arg1)
end


