require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

require 'yaml'
SITE_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'site.yml'))

module Tracksapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone =  SITE_CONFIG['time_zone']

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
    
    # Set timezone of dates in database
    config.active_record.default_timezone = :utc

    # Disable loading of the full environment when precompiling assets
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    # add /app/assets/swfs to asset pipeline for charts
    config.assets.paths << Rails.root.join("app", "assets", "swfs")

    # add print and login css to assets
    config.assets.precompile += %w(login.css print.css mobile.css)
        
    # configure Tracks to handle deployment in a subdir
    config.action_controller.relative_url_root = SITE_CONFIG['subdir'] if SITE_CONFIG['subdir']
    
    # allow onenote:// and message:// as protocols for urls
    config.action_view.sanitized_allowed_protocols = 'onenote', 'message'
    
    config.middleware.insert_after ActionDispatch::ParamsParser, ActionDispatch::XmlParamsParser
  end
end
