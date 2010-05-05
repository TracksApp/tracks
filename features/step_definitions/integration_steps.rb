Then /^I should see a message that you need a context to see scripts$/ do
  Then 'I should see "You do not have any context yet. The script will be available after you add your first context"'
end

Then /^I should see scripts$/ do
  # check on a small snippet of the first applescript
  Then 'I should see "set returnValue to call xmlrpc"'
end

Then /^I should see a script "([^\"]*)" for "([^\"]*)"$/ do |script, context_name|
  selenium.is_visible(script)
  context = Context.find_by_name(context_name)

  # wait for the script to refresh
  wait_for :timeout => 15 do
    selenium.is_text_present("#{context.id} (* #{context_name} *)")
  end

  # make sure the text is found within the textarea
  script_source = selenium.get_text("//textarea[@id='#{script}']")
  script_source.should =~ /#{context.id} \(\* #{context_name} \*\)/
end

