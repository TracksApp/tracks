When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  click_link "delete_context_#{context.id}"
  selenium.get_confirmation.should == "Are you sure that you want to delete the context '#{context_name}'? Be aware that this will also delete all (repeating) actions in this context!"
  wait_for do
    !selenium.is_element_present("delete_context_#{context.id}")
  end
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  click_link "edit_context_#{@context.id}"

  wait_for do
    selenium.is_element_present("submit_context_#{@context.id}")
  end

  fill_in "context_name", :with => new_name

  selenium.click "submit_context_#{@context.id}",
    :wait_for => :text,
    :text => "Context saved",
    :timeout => 5

  wait_for do
    !selenium.is_element_present("submit_context_#{@context.id}")
  end
end

When /^I add a new context "([^"]*)"$/ do |context_name|
  fill_in "context[name]", :with => context_name
  submit_new_context_form
end

When /^I add a new active context "([^"]*)"$/ do |context_name|
  When "I add a new context \"#{context_name}\""
end

When /^I add a new hidden context "([^"]*)"$/ do |context_name|
  fill_in "context[name]", :with => context_name
  check "context_hide"
  submit_new_context_form
end

Then /^context "([^"]*)" should be above context "([^"]*)"$/ do |context_high, context_low|
  high_id = @current_user.contexts.find_by_name(context_high).id
  low_id = @current_user.contexts.find_by_name(context_low).id
  high_pos = selenium.get_element_position_top("//div[@id='context_#{high_id}']").to_i
  low_pos = selenium.get_element_position_top("//div[@id='context_#{low_id}']").to_i
  (high_pos < low_pos).should be_true
end

When /^I drag context "([^"]*)" below context "([^"]*)"$/ do |context_drag, context_drop|
  drag_id = @current_user.contexts.find_by_name(context_drag).id
  drop_id = @current_user.contexts.find_by_name(context_drop).id

  container_height = selenium.get_element_height("//div[@id='container_context_#{drag_id}']").to_i
  vertical_offset = container_height*2
  coord_string = "10,#{vertical_offset}"

  drag_context_handle_xpath = "//div[@id='context_#{drag_id}']//span[@class='handle']"
  drop_context_container_xpath = "//div[@id='container_context_#{drop_id}']"

  selenium.mouse_down_at(drag_context_handle_xpath,"2,2")
  selenium.mouse_move_at(drop_context_container_xpath,coord_string)
  # no need to simulate mouse_over for this test
  selenium.mouse_up_at(drop_context_container_xpath,coord_string)
end

Then /^I should see that a context named "([^"]*)" is not present$/ do |context_name|
  Then "I should not see \"#{context_name}\""
end

Then /^I should see that the context container for (.*) contexts is not present$/ do |state|
  selenium.is_visible("list-#{state}-contexts-container").should_not be_true
end

Then /^I should see that the context container for (.*) contexts is present$/ do |state|
  selenium.is_visible("list-#{state}-contexts-container").should be_true
end

Then /^I should see the context "([^"]*)" under "([^"]*)"$/ do |context_name, state|
  context = Context.find_by_name(context_name)
  context.should_not be_nil
  response.should have_xpath("//div[@id='list-contexts-#{state}']//div[@id='context_#{context.id}']")
end

Then /^the new context form should be visible$/ do
  selenium.is_visible("context_new").should be_true
end

Then /^the new context form should not be visible$/ do
  selenium.is_visible("context_new").should be_false
end

Then /^the context list badge for ([^"]*) contexts should show (\d+)$/ do |state_name, count|
  selenium.get_text("xpath=//span[@id='#{state_name}-contexts-count']").should == count
end
