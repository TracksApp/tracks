Then /^I should see a message that you need a context to see scripts$/ do
  step 'I should see "You do not have any context yet. The script will be available after you add your first context"'
end

Then /^I should see scripts$/ do
  # check on a small snippet of the first applescript
  step 'I should see "set returnValue to call xmlrpc"'
end

Then /^I should see a script "([^\"]*)" for "([^\"]*)"$/ do |script, context_name|
  page.should have_css("##{script}", :visible => true)
  context = Context.find_by_name(context_name)

  page.should have_content("#{context.id} (* #{context_name} *)")

  # make sure the text is found within the textarea
  script_source = page.find(:xpath, "//textarea[@id='#{script}']").text
  script_source.should =~ /#{context.id} \(\* #{context_name} \*\)/
end

