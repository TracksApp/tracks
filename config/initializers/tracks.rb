#require 'name_part_finder'
#require 'tracks/todo_list'
#require 'tracks/config'
#require 'tagging_extensions' # Needed for tagging-specific extensions
# require 'digest/sha1' #Needed to support 'rake db:fixtures:load' on some ruby installs: http://dev.rousette.org.uk/ticket/557

# TODO: move to devise for authentication which handles ldap, cas and openid
if ( SITE_CONFIG['authentication_schemes'].include? 'ldap')
  require 'net/ldap' #requires ruby-net-ldap gem be installed
  require 'simple_ldap_authenticator'
  ldap =  SITE_CONFIG['ldap']
  SimpleLdapAuthenticator.ldap_library = ldap['library']
  SimpleLdapAuthenticator.servers = ldap['servers']
  SimpleLdapAuthenticator.use_ssl = ldap['ssl']
  SimpleLdapAuthenticator.login_format = ldap['login_format']
end

# OpenID is not supported currently!
#
# if ( SITE_CONFIG['authentication_schemes'].include? 'open_id')
#   #requires ruby-openid gem to be installed
#   OpenID::Util.logger = RAILS_DEFAULT_LOGGER
# end

if ( SITE_CONFIG['authentication_schemes'].include? 'cas')
  #requires rubycas-client gem to be installed
  if defined? CASClient
    require 'casclient/frameworks/rails/filter'
    CASClient::Frameworks::Rails::Filter.configure(
        :cas_base_url => SITE_CONFIG['cas_server'] ,
        :cas_server_logout => SITE_CONFIG['cas_server_logout']
      )
  end
end

# changed in development.rb to show under_construction bar
NOTIFY_BAR = "" unless defined?(NOTIFY_BAR)

tracks_version='2.2devel'
# comment out next two lines if you do not want (or can not) the date of the
# last git commit in the footer
info=`git log --pretty=format:"%ai" -1`
tracks_version=tracks_version + ' ('+info+')'

TRACKS_VERSION=tracks_version
