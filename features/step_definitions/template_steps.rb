Given /^a template that looks like$/ do |template|
  steps %{
      Given a file named "template.txt" with:
        """
        #{template}
        """
      }
end

When /^I execute the script$/ do
  step "I cd to \"../..\""
  
  context_id = @current_user.contexts.first.id
  port = Capybara.current_session.driver.rack_server.port
  
  # assumes there is a context with id=1
  cli = "ruby doc/tracks_template_cli.rb -c #{context_id} -f tmp/aruba/template.txt"
  
  set_env('GTD_LOGIN','testuser')
  set_env('GTD_PASSWORD', 'secret')
  set_env('GTD_TODOS_URL', 'http://localhost:#{port}/todos.xml')
  set_env('GTD_PROJECTS_URL', "http://localhost:#{port}/projects.xml")
  set_env('GTD_CONTEXT_URL_PREFIX', "http://localhost:#{port}/contexts/")
  set_env("GTD_CONTEXT_URL","http://localhost:#{port}/contexts.xml")
    
  step "I run `#{cli}`"
end