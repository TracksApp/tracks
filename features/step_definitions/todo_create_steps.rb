When /^I submit a new action with description "([^"]*)"$/ do |description|
  fill_in "todo[description]", :with => description
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  fill_in "todo[description]", :with => description
  fill_in "tag_list", :with => tags

  # fill_in does not seem to work when the field is prefilled with something. Empty the field first
  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name
  submit_next_action_form
end

When /^I submit a new deferred action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name

  fill_in "tag_list", :with => tags
  fill_in "todo[show_from]", :with => format_date(@current_user.time + 1.week)
  submit_next_action_form
end

When /^I submit a new deferred action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_project_name_from_next_action_form
  clear_context_name_from_next_action_form

  fill_in "todo_project_name", :with => project_name
  fill_in "todo_context_name", :with => context_name
  fill_in "tag_list", :with => tags
  fill_in "todo[show_from]", :with => format_date(@current_user.time + 1.week)

  submit_next_action_form
end

When /^I submit a deferred new action with description "([^"]*)" to project "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, context_name|
  When "I submit a new deferred action with description \"#{description}\" to project \"#{project_name}\" with tags \"\" in the context \"#{context_name}\""
end

When /^I submit a new deferred action with description "([^"]*)"$/ do |description|
  fill_in "todo[description]", :with => description
  fill_in "todo[show_from]", :with => format_date(@current_user.time + 1.week)
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_project_name_from_next_action_form
  clear_context_name_from_next_action_form

  fill_in "todo_project_name", :with => project_name
  fill_in "todo_context_name", :with => context_name
  fill_in "tag_list", :with => tags

  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" to project "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, context_name|
  When "I submit a new action with description \"#{description}\" to project \"#{project_name}\" with tags \"\" in the context \"#{context_name}\""
end


When /^I submit a new action with description "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  fill_in "todo[description]", :with => description

  clear_context_name_from_next_action_form
  fill_in "todo_context_name", :with => context_name

  submit_next_action_form
end

When /^I submit multiple actions with using$/ do |multiple_actions|
  fill_in "todo[multiple_todos]", :with => multiple_actions
  submit_multiple_next_action_form
end

When /^I fill the multiple actions form with "([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)"$/ do |descriptions, project_name, context_name, tags|
  fill_in "todo[multiple_todos]", :with => descriptions
  fill_in "multi_todo_project_name", :with => project_name
  fill_in "multi_todo_context_name", :with => context_name
  fill_in "multi_tag_list", :with => tags
end

When /^I submit the new multiple actions form with "([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)"$/ do |descriptions, project_name, context_name, tags|
  When "I fill the multiple actions form with \"#{descriptions}\", \"#{project_name}\", \"#{context_name}\", \"#{tags}\""
  submit_multiple_next_action_form
end

When /^I submit the new multiple actions form with$/ do |multi_line_descriptions|
  fill_in "todo[multiple_todos]", :with => multi_line_descriptions
  submit_multiple_next_action_form
end
