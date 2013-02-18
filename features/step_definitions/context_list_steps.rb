When /^I delete the context "([^\"]*)"$/ do |context_name|
  context = @current_user.contexts.find_by_name(context_name)
  context.should_not be_nil
  
  handle_js_confirm do
    click_link "delete_context_#{context.id}"
  end
  get_confirm_text.should == "Are you sure that you want to delete the context '#{context_name}'? Be aware that this will also delete all (repeating) actions in this context!"

  # wait until the context is removed
  page.should_not have_css("a#delete_context_#{context.id}")
end

When /^I edit the context to rename it to "([^\"]*)"$/ do |new_name|
  find("a#link_edit_context_#{@context.id}").click

  # wait for the form to appear (which included a submit button)
  page.should have_css("button#submit_context_#{@context.id}", :visible=>true)

  within "div.edit-form" do  
    fill_in "context_name", :with => new_name
    click_button "submit_context_#{@context.id}"
  end

  # wait for the form to go away
  page.should_not have_css("button#submit_context_#{@context.id}", :visible => true)
  # wait for the changed context to appear
  page.should have_css("a#link_edit_context_#{@context.id}", :visible=> true)
end

When /^I add a new context "([^"]*)"$/ do |context_name|
  fill_in "context[name]", :with => context_name
  submit_new_context_form
end

When /^I add a new active context "([^"]*)"$/ do |context_name|
  step "I add a new context \"#{context_name}\""
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
  
  page.execute_script "$('#{sortable_css}').simulateDragSortable({move: #{drop_index-drag_index}, handle: '.grip'});"
end

Then /^context "([^"]*)" should be above context "([^"]*)"$/ do |context_high, context_low|
  context_list_find_index(context_high).should < context_list_find_index(context_low)
end

Then /^I should see that a context named "([^"]*)" (is|is not) present$/ do |context_name, present|
  is_not = present=="is not" ? "not " : ""
  within "div#display_box" do
    step "I should #{is_not}see \"#{context_name}\""
  end
end

Then /^I should see that the context container for (.*) contexts is not present$/ do |state|
  page.should_not have_css("div#list-#{state}-contexts-container", :visible => true)
end

Then /^I should see that the context container for (.*) contexts is present$/ do |state|
  page.should have_css("div#list-#{state}-contexts-container", :visible => true)
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

Then /^I should (see|not see) empty message for (active|hidden) contexts$/ do |visible, state|
  box = (state=='active') ? "div#active-contexts-empty-nd" : "div#hidden-contexts-empty-nd"

  elem = page.find(box)
  elem.should_not be_nil

  elem.send(visible=="see" ? "should" : "should_not", be_visible)
end