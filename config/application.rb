require_relative 'boot'

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

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.time_zone = SITE_CONFIG['time_zone']

    # configure Tracks to handle deployment in a subdir
    config.relative_url_root = SITE_CONFIG['subdir'] if SITE_CONFIG['subdir']
  end
end
