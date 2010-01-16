class SwitchEnvironmentController < ActionController::Base
  def index
    readme_path = File.expand_path File.join(File.dirname(__FILE__), '..', 'README')
    render :status => 500, :locals => {:readme_path => readme_path }, :inline => <<END
<p>
  Selenium on Rails is only activated for <%= SeleniumOnRailsConfig.get(:environments).join ', ' %>
  environment<%= SeleniumOnRailsConfig.get(:environments).size > 1 ? 's' : '' %> (you're running
  <%= RAILS_ENV %>).
</p>
<p>
  Start your server in a different environment or see <tt><%= readme_path %></tt> 
  for information regarding how to change this behavior.
</p>
END
  end
end