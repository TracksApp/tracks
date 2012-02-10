Then /^I see the project "([^"]*)" in the "([^"]*)" list$/ do |name, state|
  project = @current_user.projects.find_by_name(name)
  project.should_not be_nil

  xpath = "//div[@id='list-#{state}-projects']//div[@id='project_#{project.id}']"
  response.should have_xpath(xpath)
end


