module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      root_path
    when /the home page/
      root_path
    when /the statistics page/
      stats_path
    when /the signup page/
      signup_path
    when /the login page/
      login_path
    when /the notes page/
      notes_path
    when /the contexts page/
      contexts_path
    when /the manage users page/
      users_path
    when /the repeating todos page/
      recurring_todos_path
    when /the integrations page/
      integrations_path
    
    # Add more page name => path mappings here
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

World(NavigationHelpers)
