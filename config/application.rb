require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = SITE_CONFIG['time_zone']

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # configure Tracks to handle deployment in a subdir
    config.relative_url_root = SITE_CONFIG['subdir'] if SITE_CONFIG['subdir']

    # allow onenote:// and message:// as protocols for urls
    config.action_view.sanitized_allowed_protocols = 'onenote', 'message'

    config.middleware.insert_after ActionDispatch::ParamsParser, ActionDispatch::XmlParamsParser
  end
end
