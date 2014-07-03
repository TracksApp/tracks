Given /^a template that looks like$/ do |template|
  steps %{
      Given a file named "template.txt" with:
        """
        #{template}
        """
      }
end

Given /^a console input that looks like$/ do |input|
  steps %{
    Given a file named "todo.txt" with:
      """
      #{input}
      """
    }
end

When /^I execute the template script$/ do
  step "I cd to \"../..\""
  
  context_id = @current_user.contexts.first.id
  port = Capybara.current_session.server.port
  
  # assumes there is a context with id=1
  cli = "ruby doc/tracks_template_cli.rb -c #{context_id} -f tmp/aruba/template.txt"
  
  set_env('GTD_LOGIN','testuser')
  set_env('GTD_PASSWORD', 'secret')
  set_env('GTD_TODOS_URL', "http://localhost:#{port}/todos.xml")
  set_env('GTD_PROJECTS_URL', "http://localhost:#{port}/projects.xml")
  set_env('GTD_CONTEXT_URL_PREFIX', "http://localhost:#{port}/contexts/")
  set_env("GTD_CONTEXT_URL","http://localhost:#{port}/contexts.xml")
    
  step "I run `#{cli}`"
end

When /^I execute the add-todo script$/ do
  step "I cd to \"../..\""
  
  # assumes there is a context and a project
  context_id = @current_user.contexts.first.id
  project_id = @current_user.projects.first.id
  port = Capybara.current_session.server.port
  
  cli = "ruby doc/tracks_cli_client.rb -c #{context_id} -p #{project_id}"
  
  set_env('GTD_LOGIN','testuser')
  set_env('GTD_PASSWORD', 'secret')
  set_env('GTD_TODOS_URL', "http://localhost:#{port}/todos.xml")
    
  step "I run `#{cli}` interactively"
  step "I pipe in the file \"tmp/aruba/todo.txt\""

  # it seems aruba does not wait for process to end with interactively run command, but 
  # continues anyway which will start cleaning up the database while the process is still running
  # so wait 2.5 secs for the process to finish
  sleep 2.5
end