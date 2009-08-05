When /^I visit the "([^\"]*)" project$/ do |project_name|
  project = Project.find_by_name(project_name)
  visit project_path(project)
end
