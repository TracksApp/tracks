module UJS
  PLUGIN_NAME = 'unobtrusive_javascript'
  PLUGIN_PATH = "#{RAILS_ROOT}/vendor/plugins/#{PLUGIN_NAME}"
  PLUGIN_ASSET_PATH = "#{PLUGIN_PATH}/assets"
  PLUGIN_CONTROLLER_PATH = "#{PLUGIN_PATH}/lib/controllers"
  
  class Settings
    # All elements with attached behaviours that do not
    # have an HTML +id+ attribute will have one
    # generated automatically, using the form _prefix_x_,
    # where the default prefix is "uj_element_" and x is an
    # automatically incremented number. You can set the
    # generated prefix to anything you like by setting it in your
    # environment.rb file:
    #
    #   UJS::Settings.generated_id_prefix = "my_prefix_"
    cattr_accessor :generated_id_prefix
    @@generated_id_prefix = "uj_element_"
  end
  
  class << self
    # Adds routes to your application necessary for the plugin to function correctly.
    # Simply add the following inside your Routes.draw block in routes.rb:
    #   UJS::routes
    # This is now *mandatory*.
    def routes
      ActionController::Routing::Routes.add_route "/behaviours/*page_path", :controller => "unobtrusive_javascript", :action => "generate"
    end
    
    alias_method :use_fake_script_links, :routes
  end
end