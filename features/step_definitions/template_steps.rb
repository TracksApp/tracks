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
  
  # assumes there is a context with id=1
  cli = "ruby doc/tracks_template_cli.rb -c #{context_id} -f tmp/aruba/template.txt"
  login = "GTD_LOGIN=testuser"
  pass = "GTD_PASSWORD=secret"
  port = Capybara.current_session.driver.rack_server.port
  gtd_todos_url = "GTD_TODOS_URL=http://localhost:#{port}/todos.xml"
  gtd_projects_url = "GTD_PROJECTS_URL=http://localhost:#{port}/projects.xml"
  gtd_context_url_prefix = "GTD_CONTEXT_URL_PREFIX=http://localhost:#{port}/contexts/"
  gtd_context_url = "GTD_CONTEXT_URL=http://localhost:#{port}/contexts.xml"
  
  command = "#{gtd_todos_url} #{gtd_projects_url} #{gtd_context_url_prefix} #{gtd_context_url} #{login} #{pass} #{cli}"
  
  step "I run \"#{command}\""
  # puts "output = #{combined_output}"
end