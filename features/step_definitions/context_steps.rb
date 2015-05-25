Given /^I have no contexts$/ do
  # should probably not be needed as you use this given at the start of a scenario
  Context.delete_all
end

Given /^there exists (an active|a hidden|a closed) context called "([^"]*)" for user "([^"]*)"$/ do |state, context_name, login|
  user = User.where(:login => login).first
  expect(user).to_not be_nil
  context_state = {"an active" => "active", "a hidden" => "hidden", "a closed" => "closed"}[state]
  @context = user.contexts.where(:name => context_name, :state => context_state).first_or_create
end

Given /^there exists a context called "([^"]*)" for user "([^"]*)"$/ do |context_name, login|
  step "there exists an active context called \"#{context_name}\" for user \"#{login}\""
end

Given /^I have a context called "([^\"]*)"$/ do |context_name|
  step "there exists an active context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have (an active|a hidden|a closed) context called "([^\"]*)"$/ do |state, context_name|
  step "there exists #{state} context called \"#{context_name}\" for user \"#{@current_user.login}\""
end

Given /^I have the following contexts:$/ do |table|
  table.hashes.each do |context|
    step 'I have a context called "'+context[:context]+'"'
    @context.state = (context[:hide] == "true") ? 'hidden' : 'active' unless context[:hide].blank?
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
  wait_for_ajax
end

Then /^I should see the context name is "([^\"]*)"$/ do |context_name|
  step "I should see \"#{context_name}\""
end

Then /^he should see that a context named "([^\"]*)" (is|is not) present$/ do |context_name, visible|
  context = @current_user.contexts.where(:name => context_name).first
  if visible == "is"
    expect(context).to_not be_nil
    css = "div#context_#{context.id} div.context_description a"
    expect(page).to have_selector(css, :visible => true)
    expect(page.find(:css, css).text).to eq(context_name)
  else
    expect(page).to_not have_selector("div#context_#{context.id} div.context_description a", :visible => true) if context
  end
end
