module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    options = @mobile_interface ? {:format => :m} : {}
    case page_name

    when /the home\s?page/
      root_path(options)
    when /the statistics page/
      stats_path(options)
    when /the signup page/
      signup_path(options)
    when /the login page/
      login_path(options)
    when /the notes page/
      notes_path(options)
    when /the contexts page/
      contexts_path(options)
    when /the projects page/
      projects_path(options)
    when /the manage users page/
      users_path(options)
    when /the repeating todos page/
      recurring_todos_path(options)
    when /the integrations page/
      integrations_path(options)
    when /the tickler page/
      tickler_path(options)
    when /the export page/
      data_path(options)
    when /the preference page/
      preferences_path(options)
    when /the rest api docs page/
      rest_api_docs_path(options)
    when /the search page/
      search_path(options)
    when /the starred page/
      tag_path("starred", options)
    when /the feeds page/
      feeds_path(options)
    when /the context page for "([^\"]*)" for user "([^\"]*)"/i
      context_path(User.find_by_login($2).contexts.find_by_name($1), options)
    when /the context page for "([^\"]*)"/i
      context_path(@current_user.contexts.find_by_name($1), options)
    when /the "([^\"]*)" project for user "([^\"]*)"/i
      project_path(User.find_by_login($2).projects.find_by_name($1), options)
    when /the "([^\"]*)" project/i
      @project = @current_user.projects.find_by_name($1)
      project_path(@project, options)
    when /the tag page for "([^"]*)"/i
      tag_path($1, options)

      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
