When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  
  handle_js_confirm do
    click_link "delete_context_#{context.id}"
  end
  get_confirm_text.should == "Are you sure that you want to delete the context '#{context_name}'? Be aware that this will also delete all (repeating) actions in this context!"
  wait_for_animations_to_end
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  find("a#link_edit_context_#{@context.id}").click
  
  wait_until do
    page.has_css?("button#submit_context_#{@context.id}")
  end
  
  fill_in "context_name", :with => new_name

  click_button "submit_context_#{@context.id}"
  
  wait_until do
    !page.has_css?("button#submit_context_#{@context.id}", :visible=>true)
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

When /^I drag context "([^"]*)" above context "([^"]*)"$/ do |context_drag, context_drop|
  drag_id = @current_user.contexts.find_by_name(context_drag).id
  sortable_css = "div.ui-sortable div#container_context_#{drag_id}"

  drag_index = context_list_find_index(context_drag)
  drop_index = context_list_find_index(context_drop)
  
  page.execute_script "$('#{sortable_css}').simulateDragSortable({move: #{drop_index-drag_index}, handle: '.handle'});"
end

Then /^context "([^"]*)" should be above context "([^"]*)"$/ do |context_high, context_low|
  context_list_find_index(context_high).should < context_list_find_index(context_low)
end

Then /^I should see that a context named "([^"]*)" is not present$/ do |context_name|
  within "div#display_box" do
    Then "I should not see \"#{context_name}\""
  end
end

Then /^I should see that the context container for (.*) contexts is not present$/ do |state|
  page.has_css?("div#list-#{state}-contexts-container", :visible => true).should be_false
end

Then /^I should see that the context container for (.*) contexts is present$/ do |state|
  find("div#list-#{state}-contexts-container", :visible => true).should_not be_nil
end

Then /^I should see the context "([^"]*)" under "([^"]*)"$/ do |context_name, state|
  context = Context.find_by_name(context_name)
  context.should_not be_nil
  
  page.has_css?("div#list-contexts-#{state} div#context_#{context.id}").should be_true
end

Then /^the new context form should be visible$/ do
  page.has_css?("div#context_new", :visible => true).should be_true
end

Then /^the new context form should not be visible$/ do
  page.has_css?("div#context_new", :visible => true).should be_false
end

Then /^the context list badge for ([^"]*) contexts should show (\d+)$/ do |state_name, count|
  find("span##{state_name}-contexts-count").text.should == count
end
