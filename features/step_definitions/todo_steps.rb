Given /^I have no todos$/ do
  Todo.delete_all
end

Given /^I have a todo "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  context = @current_user.contexts.find_or_create(:name => context_name)
  @current_user.todos.create!(:context_id => context.id, :description => description)
end

Given /^I have a todo "([^"]*)" in the context "([^"]*)" which is due tomorrow$/ do |description, context_name|
  context = @current_user.contexts.find_or_create(:name => context_name)
  @todo = @current_user.todos.create!(:context_id => context.id, :description => description)
  @todo.due = @todo.created_at + 1.day
  @todo.save!
end

Given /^I have a todo "([^"]*)"$/ do |description|
  Given "I have a todo \"#{description}\" in the context \"Context A\""
end

Given /^I have ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    Given "I have a todo \"todo #{i}\" in the context \"Context A\""
  end
end

Given /^I have ([0-9]+) deferred todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context B")
  count.to_i.downto 1 do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}", :show_from => @current_user.time + 1.week)
  end
end

Given /^I have a deferred todo "([^"]*)"$/ do |description|
  Given "I have a deferred todo \"#{description}\" in the context \"context B\""
end

Given /^I have a deferred todo "([^"]*)" in the context "([^"]*)"$/ do |description, context_name|
  context = @current_user.contexts.find_or_create(:name => context_name)
  @current_user.todos.create!(:context_id => context.id, :description => description, :show_from => @current_user.time + 1.week)
end

Given /^I have ([0-9]+) completed todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context C")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
    todo.complete!
  end
end

Given /^I have ([0-9]+) completed todos with a note$/ do |count|
  context = @current_user.contexts.create!(:name => "context D")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}", :notes => "note #{i}")
    todo.complete!
  end
end

Given /^I have a todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |action_description, project_name, tags, context_name|
  context = @current_user.contexts.find_or_create(:name => context_name)
  project = @current_user.projects.find_or_create(:name => project_name)
  @todo = @current_user.todos.create!(:context_id => context.id, :project_id => project.id, :description => action_description)
  @todo.tag_with(tags)
  @todo.save
end

Given /^I have a todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)" that is due next week$/ do |action_description, project_name, tags, context_name|
  Given "I have a todo with description \"#{action_description}\" in project \"#{project_name}\" with tags \"#{tags}\" in the context \"#{context_name}\""
  @todo.due = @current_user.time + 1.week
  @todo.save!
end

Given /^I have a completed todo with description "([^"]*)" in project "([^"]*)" with tags "([^"]*)" in the context "([^"]*)"$/ do |action_description, project_name, tags, context_name|
  Given "I have a todo with description \"#{action_description}\" in project \"#{project_name}\" with tags \"#{tags}\" in the context \"#{context_name}\""
  @todo.complete!
end

Given /^I have a project "([^"]*)" that has the following todos$/ do |project_name, todos|
  Given "I have a project called \"#{project_name}\""
  @project.should_not be_nil
  todos.hashes.each do |todo|
    context = @current_user.contexts.find_by_name(todo[:context])
    context.should_not be_nil
    new_todo = @current_user.todos.create!(
      :description => todo[:description],
      :context_id => context.id,
      :project_id=>@project.id)
    unless todo[:tags].nil?
      new_todo.tag_with(todo[:tags])
    end
    unless todo[:completed].nil?
      new_todo.complete! if todo[:completed] == 'yes'
    end
  end
end

When /^I mark "([^"]*)" as complete$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  check "mark_complete_#{todo.id}"

  todo_container = "fail"  # fail this test if @source_view is wrong
  todo_container = "p#{todo.project_id}items" if @source_view=="project"
  todo_container = "c#{todo.context_id}items" if @source_view=="context" || @source_view=="todos" || @source_view=="tag"

  # container should be there
  selenium.is_element_present("//div[@id='#{todo_container}']").should be_true

  wait_for :timeout => 5 do
    !selenium.is_element_present("//div[@id='#{todo_container}']//div[@id='line_todo_#{todo.id}']")
  end
end

When /^I mark "([^"]*)" as uncompleted$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  check "mark_complete_#{todo.id}"

  todo_container = "fail"  # fail this test if @source_view is wrong
  todo_container = "p#{todo.project_id}items" if @source_view=="project"
  todo_container = "c#{todo.context_id}items" if @source_view=="context" || @source_view=="todos" || @source_view=="tag"

  todo_container.should_not == "fail"

  wait_for :timeout => 5 do
    selenium.is_element_present("//div[@id='#{todo_container}']//div[@id='line_todo_#{todo.id}']")
  end
end

When /^I mark the complete todo "([^"]*)" active$/ do |action_description|
  When "I mark \"#{action_description}\" as uncompleted"
end


When /^I star the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_unstarred = "//div[@id='line_todo_#{todo.id}']//img[@class='unstarred_todo']"
  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='starred_todo']"

  selenium.is_element_present(xpath_unstarred).should be_true

  star_img = "//img[@id='star_img_#{todo.id}']"
  selenium.click(star_img, :wait_for => :ajax, :javascript_framework => :jquery)

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath_starred)
  end
end

Then /^I should see a starred "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='starred_todo']"

  selenium.is_element_present(xpath_starred).should be_true
end

When /^I delete the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  delete_todo_button = "xpath=//a[@id='delete_todo_#{todo.id}']/img"
  selenium.click delete_todo_button
  selenium.get_confirmation.should == "Are you sure that you want to delete the action '#{todo.description}'?"

  wait_for :timeout => 5 do
    !selenium.is_element_present("//div[@id='line_todo_#{todo.id}']")
  end
end

When /^I delete the todo "([^"]*)"$/ do |action_description|
  When "I delete the action \"#{action_description}\""
end

Then /^I should see ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    match_xpath "div["
  end
end

Then /^there should not be an error$/ do
  sleep(5)
  # form should be gone and thus no errors visible
  wait_for :timeout => 5 do
    !selenium.is_visible("edit_todo_#{@dep_todo.id}")
  end
end

Then /^I should see the todo "([^\"]*)"$/ do |todo_description|
  selenium.is_element_present("//span[.=\"#{todo_description}\"]").should be_true
end

Then /^I should not see the todo "([^\"]*)"$/ do |todo_description|
  selenium.is_element_present("//span[.=\"#{todo_description}\"]").should be_false
end

Then /^the number of actions should be (\d+)$/ do |count|
  @current_user.todos.count.should == count.to_i
end

Then /^a confirmation for adding a new context "([^"]*)" should be asked$/ do |context_name|
  selenium.get_confirmation.should == "New context '#{context_name}' will be also created. Are you sure?"
end

Then /^I should see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should see "([^"]*)" in the action container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='p#{todo.project.id}items']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should see "([^"]*)" in the completed container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='completed_container']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^I should not see "([^"]*)" in the deferred container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='tickler']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    !selenium.is_element_present(xpath)
  end
end

Then /^I should see "([^"]*)" in the due next month container$/ do |todo_description|
  todo = @current_user.todos.find_by_description(todo_description)
  todo.should_not be_nil

  xpath = "//div[@id='due_after_this_month']//div[@id='line_todo_#{todo.id}']"

  wait_for :timeout => 5 do
    selenium.is_element_present(xpath)
  end
end

Then /^the selected project should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Project").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end

Then /^the selected context should be "([^"]*)"$/ do |content|
  # Works for mobile. TODO: make it work for both mobile and non-mobile
  field_labeled("Context").element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{content}/
end
