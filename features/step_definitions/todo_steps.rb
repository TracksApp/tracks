Given /^I have no todos$/ do
  Todo.delete_all
end

Given /^I have ([0-9]+) todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context A")
  count.to_i.downto 1 do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
  end
end

Given /^I have ([0-9]+) deferred todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context B")
  count.to_i.downto 1 do |i|
    @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}", :show_from => @current_user.time + 1.week)
  end
end

Given /^I have ([0-9]+) completed todos$/ do |count|
  context = @current_user.contexts.create!(:name => "context C")
  count.to_i.downto 1 do |i|
    todo = @current_user.todos.create!(:context_id => context.id, :description => "todo #{i}")
    todo.complete!
  end
end

Given /^"(.*)" depends on "(.*)"$/ do |successor_name, predecessor_name|
  successor = Todo.find_by_description(successor_name)
  predecessor = Todo.find_by_description(predecessor_name)
  
  successor.add_predecessor(predecessor)
  successor.state = "pending"
  successor.save!
end

When /^I drag "(.*)" to "(.*)"$/ do |dragged, target|
  drag_id = Todo.find_by_description(dragged).id
  drop_id = Todo.find_by_description(target).id
  drag_name = "xpath=//div[@id='line_todo_#{drag_id}']//img[@class='grip']"
  drop_name = "xpath=//div[@id='line_todo_#{drop_id}']//div[@class='description']"
  selenium.drag_and_drop_to_object(drag_name, drop_name)
end

Then /^I should see ([0-9]+) todos$/ do |count|
  count.to_i.downto 1 do |i|
    match_xpath "div["
  end
end

Then /^the dependencies of "(.*)" should include "(.*)"$/ do |parent_name, child_name|
   parent_id = Todo.find_by_description(parent_name).id
   assert_contain(parent_name)
end