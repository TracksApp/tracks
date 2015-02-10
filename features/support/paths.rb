module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    options = {}
    options[:format] = :m if @mobile_interface 
    options[:locale] = @locale if @locale
    options[:_group_view_by] = @group_view_by if @group_view_by
    @source_view = nil
    
    case page_name

    when /the home\s?page/
      @source_view = "todos"
      root_path(options)

    when /the done page/
      @source_view = "done"
      done_overview_path(options)
    when /the done actions page for context "([^"]*)"/i
      @source_view = "done"
      context = @current_user.contexts.where(:name => $1).first
      done_todos_context_path(context, options)
    when /the done actions page for project "([^"]*)"/i
      @source_view = "done"
      project = @current_user.projects.where(:name => $1).first
      done_todos_project_path(project, options)
    when /the done actions page for tag "([^"]*)"/i
      @source_view = "done"
      done_tag_path($1, options)
    when /the done actions page/
      @source_view = "done"
      done_todos_path(options)
    when /the all done actions page for context "([^"]*)"/i
      @source_view = "done"
      context = @current_user.contexts.where(:name => $1).first
      all_done_todos_context_path(context, options)
    when /the all done actions page for project "([^"]*)"/i
      @source_view = "done"
      project = @current_user.projects.where(:name => $1).first
      all_done_todos_project_path(project, options)
    when /the all done actions page for tag "([^"]*)"/i
      @source_view = "done"
      all_done_tag_path($1, options)
    when /the all done actions page/
      @source_view = "done"
      all_done_todos_path(options)

    when /the statistics page/
      @source_view = "stats"
      stats_path(options)
    when /the signup page/
      signup_path(options)
    when /the login page/
      login_path(options)
    when /the logout page/
      logout_path(options)
    when /the notes page/
      notes_path(options)
    when /the calendar page/
      calendar_path(options)
    when /the review page/
      @source_view = "review"
      review_path(options)
    when /the contexts page/
      @source_view = "context"
      contexts_path(options)
    when /the projects page/
      @source_view = "project"
      projects_path(options)
    when /the manage users page/
      users_path(options)
    when /the recurring todos page/
      recurring_todos_path(options)
    when /the integrations page/
      integrations_path(options)
    when /the tickler page/
      @source_view = "deferred"
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
      @source_view = "context"
      @context = User.where(:login => $2).first.contexts.where(:name => $1).first
      context_path(@context, options)
    when /the context page for "([^\"]*)"/i
      @source_view = "context"
      @context = @current_user.contexts.where(:name => $1).first
      context_path(@context, options)
    when /the "([^\"]*)" context/i
      @source_view = "context"
      @context = @current_user.contexts.where(:name => $1).first
      context_path(@context, options)
    when /the "([^\"]*)" project for user "([^\"]*)"/i
      @source_view = "project"
      @project = User.where(:login => $2).first.projects.where(:name => $1).first
      project_path(@project, options)
    when /the "([^\"]*)" project/i
      @source_view = "project"
      @project = @current_user.projects.where(:name => $1).first
      project_path(@project, options)
    when /the tag page for "([^"]*)"/i
      @source_view = "tag"
      tag_path($1, options)
    when /the change password page/
      change_password_user_path @current_user
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.where(:login => $1))first.

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
