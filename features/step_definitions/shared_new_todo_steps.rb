Then /^the single action form should be visible$/ do
  expect(page).to have_css("#todo_new_action", :visible => true)
end

Then /^the single action form should not be visible$/ do
  expect(page).to_not have_css("#todo_new_action", :visible=>true)
end

Then /^the multiple action form should be visible$/ do
  expect(page).to have_css("#todo_multi_add", :visible => true)
end

Then /^the multiple action form should not be visible$/ do
  expect(page).to_not have_css("#todo_multi_add", :visible=>true)
end