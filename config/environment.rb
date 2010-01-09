# Be sure to restart your webserver when you modify this file.
# Uncomment below to force Rails into production mode

# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'yaml'
SITE_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'site.yml'))

class Rails::Configuration
  attr_accessor :action_web_service
end

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]
  config.load_paths += %W( #{RAILS_ROOT}/app/apis )

  config.gem "highline"
  config.gem "RedCloth"
  config.gem "soap4r", :lib => false
  config.gem 'datanoise-actionwebservice', :lib => 'actionwebservice'

  config.action_controller.use_accept_header = true

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  config.action_controller.session = {
    :session_key => '_tracks_session_id',
    :secret      =>  SITE_CONFIG['salt'] * (30.0 /  SITE_CONFIG['salt'].length).ceil #must be at least 30 characters
  }

  config.action_controller.relative_url_root = SITE_CONFIG['subdir'] if SITE_CONFIG['subdir']

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  # You''ll probably want to change this to the time zone of the computer where Tracks is running
  # run rake time:zones:local have Rails suggest time zone names on your system
  config.time_zone =  SITE_CONFIG['time_zone']

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby

  # allow other protocols in urls for sanitzer. Add to your liking, for example
  # config.action_view.sanitized_allowed_protocols = 'onenote', 'blah', 'proto'
  # to enable "link":onenote://... or "link":blah://... hyperlinks
  config.action_view.sanitized_allowed_protocols = 'onenote', 'message'

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below


require 'name_part_finder'
require 'tracks/todo_list'
require 'tracks/config'
require 'tagging_extensions' # Needed for tagging-specific extensions
require 'digest/sha1' #Needed to support 'rake db:fixtures:load' on some ruby installs: http://dev.rousette.org.uk/ticket/557

if ( SITE_CONFIG['authentication_schemes'].include? 'ldap')
  require 'net/ldap' #requires ruby-net-ldap gem be installed
  require 'simple_ldap_authenticator'
  ldap =  SITE_CONFIG['ldap']
  SimpleLdapAuthenticator.ldap_library = ldap['library']
  SimpleLdapAuthenticator.servers = ldap['servers']
  SimpleLdapAuthenticator.use_ssl = ldap['ssl']
  SimpleLdapAuthenticator.login_format = ldap['login_format']
end

if ( SITE_CONFIG['authentication_schemes'].include? 'open_id')
  #requires ruby-openid gem to be installed
  OpenID::Util.logger = RAILS_DEFAULT_LOGGER
end

tracks_version='1.8devel'
# comment out next two lines if you do not want (or can not) the date of the
# last git commit in the footer
info=`git log --pretty=format:"%ai" -1`
tracks_version=tracks_version + ' ('+info+')'

TRACKS_VERSION=tracks_version
