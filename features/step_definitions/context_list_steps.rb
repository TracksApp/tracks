When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = find_context(context_name)
  
  handle_js_confirm do
    click_link "delete_context_#{context.id}"
  end
  expect(get_confirm_text).to eq("Are you sure that you want to delete the context '#{context_name}'? Be aware that this will also delete all (recurring) actions in this context!")

  # wait until the context is removed
  expect(page).to_not have_css("a#delete_context_#{context.id}")
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  find("a#link_edit_context_#{@context.id}").click

  wait_for_context_form_to_appear(@context)

  within "div.edit-form" do  
    fill_in "context_name", :with => new_name
    click_button "submit_context_#{@context.id}"
  end

  wait_for_context_form_to_go_away(@context)
end

When(/^I add a new context "([^"]*)"$/) do |context_name|
  fill_in "context[name]", :with => context_name
  submit_new_context_form
end

When(/^I add a new active context "([^"]*)"$/) do |context_name|
  step "I add a new context \"#{context_name}\""
end

When(/^I add a new hidden context "([^"]*)"$/) do |context_name|
  fill_in "context[name]", :with => context_name
  check "context_state_hide"
  submit_new_context_form
end

When(/^I drag context "([^"]*)" above context "([^"]*)"$/) do |context_drag, context_drop|
  drag_id = find_context(context_drag).id

  drag_index = context_list_find_index(context_drag)
  drop_index = context_list_find_index(context_drop)
  
  context_drag_and_drop(drag_id, drop_index-drag_index)
end

When /^I edit the state of context "(.*?)" to closed$/ do |context_name|
  context = find_context(context_name)

  open_context_edit_form(context)
  # change state
  within "form#edit_form_context_#{context.id}" do  
    find("input#context_state_closed").click
    click_button "submit_context_#{context.id}"
  end

  wait_for_context_form_to_go_away(context)
end

Then /^context "([^"]*)" should be above context "([^"]*)"$/ do |context_high, context_low|
  sleep 0.2
  expect(context_list_find_index(context_high)).to be < context_list_find_index(context_low)
end

Then(/^I should see that a context named "([^"]*)" (is|is not) present$/) do |context_name, present|
  is_not = present=="is not" ? "not " : ""
  within "div#display_box" do
    step "I should #{is_not}see \"#{context_name}\""
  end
end

Then /^I should see that the context container for (.*) contexts (is|is not) present$/ do |state, visible|
  v = {"is" => "see", "is not" => "not see"}[visible] # map is|is not to see|not see
  check_css_visibility(v, "div#list-#{state}-contexts-container" )
end

Then /^I should see the context "([^"]*)" under "([^"]*)"$/ do |context_name, state|
  context = find_context(context_name)
  check_css_visibility("see", "div#list-contexts-#{state} div#context_#{context.id}")  
end

Then /^the new context form should (be|not be) visible$/ do |visible|
  v = {"be" => "see", "not be" => "not see"}[visible] # map be|not be to see|not see
  check_css_visibility(v, "div#context_new")  
end

Then /^the context list badge for ([^"]*) contexts should show (\d+)$/ do |state_name, count|
  expect(find("span##{state_name}-contexts-count").text).to eq(count)
end

Then /^I should (see|not see) empty message for (active|hidden|closed) contexts$/ do |visible, state|
  check_css_visibility(visible, "div##{state}-contexts-empty-nd")  
end
