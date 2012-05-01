Given /^I have no contexts$/ do
  # should probably not be needed as you use this given at the start of a scenario
  Context.delete_all
end

Given /^there exists an active context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  user = User.find_by_login(login)
  user.should_not be_nil
  @context = user.contexts.find_or_create_by_name(:name => context_name, :hide => false)
end

Given /^there exists a context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  step "there exists an active context called \"#{context_name}\" for user \"#{login}\""
end

Given /^there exists a hidden context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  user = User.find_by_login(login)
  user.should_not be_nil
  @context = user.contexts.create!(:name => context_name, :hide => true)
end

Given /^I have a context called "([^\"]*)"$/ do |context_name|
  step "there exists an active context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have an active context called "([^\"]*)"$/ do |context_name|
  step "there exists an active context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have a hidden context called "([^\"]*)"$/ do |context_name|
  step "there exists a hidden context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have the following contexts:$/ do |table|
  table.hashes.each do |context|
    step 'I have a context called "'+context[:context]+'"'
    @context.hide = context[:hide] == "true" unless context[:hide].blank?
    # acts_as_list puts the last added context at the top, but we want it
    # at the bottom to be consistent with the table in the scenario
    @context.move_to_bottom
    @context.save!
  end
end

Given /^I have the following contexts$/ do |table|
  step("I have the following contexts:", table)
end

Given /^I have a context "([^\"]*)" with (\d+) (?:actions|todos)$/ do |context_name, number_of_actions|
  context = @current_user.contexts.create!(:name => context_name)
  @todos=[]
  1.upto number_of_actions.to_i do |i|
    @todos << @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
  end
end

Given /^I have a context "([^\"]*)" with (\d+) deferred (?:actions|todos)$/ do |context_name, number_of_actions|
  step "I have a context \"#{context_name}\" with #{number_of_actions} actions"
  @todos.each {|todo| todo.description = "deferred "+todo.description; todo.show_from = Time.zone.now + 1.week; todo.save!}
end

When /^I edit the context name in place to be "([^\"]*)"$/ do |new_context_name|
  page.find("span#context_name").click
  fill_in "value", :with => new_context_name
  click_button "Ok"
end

Then /^I should see the context name is "([^\"]*)"$/ do |context_name|
  step "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" (is|is not) present$/ do |context_name, visible|
  context = @current_user.contexts.find_by_name(context_name)
  if visible == "is"
    context.should_not be_nil
    css = "div#context_#{context.id} div.context_description a"
    page.should have_selector(css, :visible => true)
    page.find(:css, css).text.should == context_name
  else
    page.should_not have_selector("div#context_#{context.id} div.context_description a", :visible => true) if context
  end
end

Then /^I should (see|not see) empty message for (todo|completed todo|deferred todo)s of context/ do |visible, state|
  css = "error"
  css = "div#c#{@context.id}empty-nd" if state == "todo"
  css = "div#empty-d"                 if state == "completed todo"
  css = "div#tickler-empty-nd"        if state == "deferred todo"
  
  page.send(visible=="see" ? :should : :should_not, have_css(css, :visible=>true))
end