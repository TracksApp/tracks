Then /^the single action form should be visible$/ do
  selenium.is_visible("todo_new_action").should == true
end

Then /^the single action form should not be visible$/ do
  selenium.is_visible("todo_new_action").should == false
end

Then /^the multiple action form should be visible$/ do
  selenium.is_visible("todo_multi_add").should == true
end

Then /^the multiple action form should not be visible$/ do
  selenium.is_visible("todo_multi_add").should == false
end