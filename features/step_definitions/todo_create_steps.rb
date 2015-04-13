Given /^I have no todos$/ do
  Todo.delete_all
end

Given /^I have a todo "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  context = @current_user.contexts.where(:name => context_name).first_or_create
  @todo = @current_user.todos.create!(:context_id => context.id, :description => description)
end

Given /^I have a todo "([^"]*)" in context "([^"]*)" with tags "([^"]*)"$/ do |description, context_name, tag_names|
  step "I have a todo \"#{description}\" in the context \"#{context_name}\""
  @todo.tag_with(tag_names)
  @todo.save!
end

Given(/^I have a todo "([^"]*)" in the context "([^"]*)" in the project "([^"]*)"$/) do |description, context_name, project_name|
  step "I have a todo \"#{description}\" in the context \"#{context_name}\""

  @project = @current_user.projects.where(:name => project_name).first_or_create
  expect(@project).to_not be_nil

  @todo.project = @project
  @todo.save!
end

Given /^I have a todo "([^"]*)" in the context "([^"]*)" which is due tomorrow$/ do |description, context_name|
  context = @current_user.contexts.where(:name => context_name).first_or_create
  @todo = @current_user.todos.create!(:context_id => context.id, :description => description)
  @todo.due = @todo.created_at + 1.day
  @todo.save!
end

Given /^I have (\d+) todos in project "([^"]*)" in context "([^"]*)" with tags "([^"]*)" prefixed by "([^"]*)"$/ do |number_of_todos, project_name, context_name, tag_names, prefix|
  @context = find_context(context_name)
  @project = find_project(project_name)

  @todos = []
  number_of_todos.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => @context.id, :description => "#{prefix}todo #{i}", :project_id => @project.id)
    todo.tag_with(tag_names)
    todo.save!
    @todos << todo
  end
end

Given /^I have (\d+) todos in project "([^"]*)" in context "([^"]*)" with tags "([^"]*)"$/ do |number_of_todos, project_name, context_name, tag_names|
  step "I have #{number_of_todos} todos in project \"#{project_name}\" in context \"#{context_name}\" with tags \"#{tag_names}\" prefixed by \"\""
end

Given /^I have a todo "([^"]*)"$/ do |description|
  step "I have a todo \"#{description}\" in the context \"Context A\""
end

Given /^I have the following todos:$/ do |table|
  table.hashes.each do | todo |
    step "I have a todo \"#{todo[:description]}\" in the context \"#{todo[:context]}\""
  end
end

Given /^I have a todo "([^"]*)" with notes "([^"]*)"$/ do |description, notes|
  step "I have a todo \"#{description}\" in the context \"Context A\""
  @todo.notes = notes
  @todo.save!
end

Given /^I have ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    step "I have a todo \"todo #{i}\" in the context \"Context A\""
  end
end

Given /^I have a todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |action_description, project_name, tags, context_name|
  @context = @current_user.contexts.where(:name => context_name).first_or_create
  @project = @current_user.projects.where(:name => project_name).first_or_create
  @todo = @current_user.todos.create!(:context_id => @context.id, :project_id => @project.id, :description => action_description)
  @todo.tag_with(tags)
  @todo.save
end

Given /^I have a todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)" that is due next week$/ do |action_description, project_name, tags, context_name|
  step "I have a todo with description \"#{action_description}\" in project \"#{project_name}\" with tags \"#{tags}\" in the context \"#{context_name}\""
  @todo.due = UserTime.new(@current_user).time + 1.week
  @todo.save!
end

Given(/^I have a todo "(.*?)" in context "(.*?)" in project "(.*?)" with tags "(.*?)"$/) do |action_description, context_name, project_name, tags|
  step "I have a todo with description \"#{action_description}\" in project \"#{project_name}\" with tags \"#{tags}\" in the context \"#{context_name}\"" 
end


###### DEFERRED TODOS #######

Given /^I have ([0-9]+) deferred todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context B")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
    todo.show_from = UserTime.new(@current_user).time + 1.week
    todo.save!
  end
end

Given /^I have a deferred todo "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  step "I have a deferred todo \"#{description}\" in the context \"#{context_name}\" deferred by 7 days"
end

Given /^I have a (?:deferred )todo "([^"]*)" in the context "([^"]*)" deferred by (\d+) day(?:s)?$/ do |description, context_name, deferred_by_days|
  context = @current_user.contexts.where(:name => context_name).first_or_create
  todo = @current_user.todos.create!(:context_id => context.id, :description => description)
  todo.show_from = UserTime.new(@current_user).time + deferred_by_days.to_i.day
  todo.save!
end

Given /^I have a deferred todo "([^"]*)"$/ do |description|
  step "I have a deferred todo \"#{description}\" in the context \"context B\""
end

Given /^I have a deferred todo "([^"]*)" in context "([^"]*)" with tags "([^"]*)"$/ do |action_description, context_name, tag_list|
  step "I have a todo \"#{action_description}\" in context \"#{context_name}\" with tags \"#{tag_list}\""
  @todo.show_from = UserTime.new(@current_user).time + 1.week
  @todo.save!
end

Given(/^I have a deferred todo "(.*?)" in the context "(.*?)" in the project "(.*?)"$/) do |action_description, context_name, project_name|
  step "I have a todo \"#{action_description}\" in the context \"#{context_name}\" in the project \"#{project_name}\""
  @todo.show_from = UserTime.new(@current_user).time + 1.week
  @todo.save!
end


####### COMPLETED TODOS #######

Given /^I have ([0-9]+) completed todos in project "([^"]*)" in context "([^"]*)"$/ do |count, project_name, context_name|
  @context = find_context(context_name)
  @project = find_project(project_name)

  @todos = []
  count.to_i.downto 1 do |i|
    @todo = @current_user.todos.create!(:context_id => @context.id, :description => "todo #{i}", :project_id => @project.id)
    @todo.complete!
    @todos << @todo
  end
end

Given /^I have a completed todo "([^"]*)" in project "([^"]*)" in context "([^"]*)"$/ do |action_description, project_name, context_name|
  step "I have 1 completed todos in project \"#{project_name}\" in context \"#{context_name}\""
  @todos[0].description = action_description
  @todos[0].save!
end

Given /^I have (\d+) completed todos in project "([^"]*)" in context "([^"]*)" with tags "([^"]*)"$/ do  |count, project_name, context_name, tags|
  step "I have #{count} completed todos in project \"#{project_name}\" in context \"#{context_name}\""
  @todos.each { |t| t.tag_with(tags); t.save! }
end

Given(/^I have ([0-9]+) completed todos in context "([^"]*)"$/) do |count, context_name|
  context = find_context(context_name)

  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
    todo.complete!
  end
end

Given /^I have ([0-9]+) completed todos$/ do |count|
  step "I have a context called \"context D\""
  step "I have #{count} completed todos in context \"context D\""
end

Given /^I have ([0-9]+) completed todos with a note$/ do |count|
  step "I have #{count} completed todos"
  @todos.each { |t| t.notes = "note #{t.id}"; t.save!}
end

Given /^I have ([0-9]+) completed todos with a note in project "([^"]*)" in context "([^"]*)" with tags "([^"]*)"$/ do |count, project_name, context_name, tags|
  step "I have #{count} completed todos in project \"#{project_name}\" in context \"#{context_name}\" with tags \"#{tags}\""
  @todos.each { |t| t.notes = "note #{t.id}"; t.save! }
end

Given /^I have a completed todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |action_description, project_name, tags, context_name|
  step "I have a todo with description \"#{action_description}\" in project \"#{project_name}\" with tags \"#{tags}\" in the context \"#{context_name}\""
  @todo.complete!
end

Given(/^I have a completed todo with description "([^"]*)" in context "(.*?)" completed (\d+) days ago$/) do |action_description, context_name, num_of_days|
  step "I have a todo \"#{action_description}\" in the context \"#{context_name}\""
  @todo.complete!
  @todo.completed_at = Time.zone.now - num_of_days.to_i.days
  @todo.save!
  @todo.reload
end

####### PROJECT WITH TODOS ######

Given /^I have a project "([^"]*)" that has the following (todos|deferred todos)$/ do |project_name, kind_of_todo, todos|
  step "I have a project called \"#{project_name}\""
  expect(@project).to_not be_nil

  todos.hashes.each do |todo|
    new_todo = @current_user.todos.create!(
      :description => todo[:description],
      :context_id  => find_context(todo[:context]).id,
      :project_id  => @project.id,
      :notes       => todo[:notes])
    new_todo.show_from = Time.zone.now+1.week if kind_of_todo=="deferred todos"
    new_todo.tag_with(todo[:tags]) unless todo[:tags].nil?
    new_todo.complete! if !todo[:completed].nil? && todo[:completed] == 'yes' 
    new_todo.save!
  end
end

####### submitting using sidebar form #######

When /^I submit a new action with description "([^"]*)"$/ do |description|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description
  end
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" in the project "(.*?)"$/ do |description, project_name|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description
    fill_in "project_name", :with => project_name
  end
  submit_next_action_form
end

When(/^I submit a new action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)"$/) do |description, project_name, tags|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description
    fill_in "project_name", :with => project_name
    fill_in "tag_list", :with => tags
  end
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" with a dependency on "([^"]*)"$/ do |todo_description, predecessor_description|
  predecessor = find_todo(predecessor_description)

  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => todo_description
    fill_in "predecessor_input", :with => predecessor_description
  end

  wait_for_auto_complete 
  click_first_line_of_auto_complete

  new_dependency_line = "//li[@id='pred_#{predecessor.id}']"
  expect(page).to have_xpath(new_dependency_line, :visible => true)

  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description
    fill_in "tag_list", :with => tags

    # fill_in does not seem to work when the field is prefilled with something. Empty the field first
    clear_context_name_from_next_action_form
    fill_in "todo_context_name", :with => context_name
  end
  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, tags, context_name|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description

    clear_project_name_from_next_action_form
    clear_context_name_from_next_action_form

    fill_in "todo_project_name", :with => project_name
    fill_in "todo_context_name", :with => context_name
    fill_in "tag_list", :with => tags
  end

  submit_next_action_form
end

When /^I submit a new action with description "([^"]*)" to project "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, context_name|
  step "I submit a new action with description \"#{description}\" to project \"#{project_name}\" with tags \"\" in the context \"#{context_name}\""
end

When /^I submit a new action with description "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description

    clear_context_name_from_next_action_form
    fill_in "todo_context_name", :with => context_name
  end

  submit_next_action_form
end

####### submitting using sidebar form: DEFERRED #######

When(/^I submit a new deferred action with description "([^"]*)"$/) do |description|
  fill_in "todo[description]", :with => description
  fill_in "todo[show_from]", :with => format_date(UserTime.new(@current_user).time + 1.week)
  submit_next_action_form
end

When /^I submit a new deferred action with description "([^"]*)" and the tags "([^"]*)" in the context "([^"]*)"$/ do |description, tags, context_name|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description

    clear_context_name_from_next_action_form
    fill_in "todo_context_name", :with => context_name

    fill_in "tag_list", :with => tags
    fill_in "todo[show_from]", :with => format_date(UserTime.new(@current_user).time + 1.week)
  end
  submit_next_action_form
end

When(/^I submit a new deferred action with description "([^"]*)" to project "(.*?)" with tags "([^"]*)"$/) do |description, project_name, tags|
  within "form#todo-form-new-action" do
    fill_in "todo[description]", :with => description
    fill_in "todo_project_name", :with => project_name
    fill_in "tag_list", :with => tags
    fill_in "todo[show_from]", :with => format_date(UserTime.new(@current_user).time + 1.week)
  end
  submit_next_action_form
end

When /^I submit a new deferred action with description "([^"]*)" to project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, tags, context_name|
  fill_in "todo[description]", :with => description

  clear_project_name_from_next_action_form
  clear_context_name_from_next_action_form

  within "form#todo-form-new-action" do
    fill_in "todo_project_name", :with => project_name
    fill_in "todo_context_name", :with => context_name
    fill_in "tag_list", :with => tags
    fill_in "todo[show_from]", :with => format_date(UserTime.new(@current_user).time + 1.week)
  end

  submit_next_action_form
end

When /^I submit a deferred new action with description "([^"]*)" to project "([^"]*)" in the context "([^"]*)"$/ do |description, project_name, context_name|
  step "I submit a new deferred action with description \"#{description}\" to project \"#{project_name}\" with tags \"\" in the context \"#{context_name}\""
end

####### submitting using sidebar form: MULTIPLE ACTIONS #######

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
  step "I fill the multiple actions form with \"#{descriptions}\", \"#{project_name}\", \"#{context_name}\", \"#{tags}\""
  submit_multiple_next_action_form
end

When /^I submit the new multiple actions form with$/ do |multi_line_descriptions|
  fill_in "todo[multiple_todos]", :with => multi_line_descriptions
  submit_multiple_next_action_form
end
