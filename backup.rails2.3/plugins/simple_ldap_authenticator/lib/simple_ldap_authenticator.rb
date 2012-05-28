# SimpleLdapAuthenticator
#
# This plugin supports both Ruby/LDAP and Net::LDAP, defaulting to Ruby/LDAP
# if it is available.  If both are installed and you want to force the use of 
# Net::LDAP, set SimpleLdapAuthenticator.ldap_library = 'net/ldap'.

# Allows for easily authenticating users via LDAP (or LDAPS).  If authenticating
# via LDAP to a server running on localhost, you should only have to configure
# the login_format.
#
# Can be configured using the following accessors (with examples):
# * login_format = '%s@domain.com' # Active Directory, OR
# * login_format = 'cn=%s,cn=users,o=organization,c=us' # Other LDAP servers
# * servers = ['dc1.domain.com', 'dc2.domain.com'] # names/addresses of LDAP servers to use
# * use_ssl = true # for logging in via LDAPS
# * port = 3289 # instead of 389 for LDAP or 636 for LDAPS
# * logger = RAILS_DEFAULT_LOGGER # for logging authentication successes/failures
#
# The class is used as a global variable, you are not supposed to create an
# instance of it. For example:
#
#    require 'simple_ldap_authenticator'
#    SimpleLdapAuthenticator.servers = %w'dc1.domain.com dc2.domain.com'
#    SimpleLdapAuthenticator.use_ssl = true
#    SimpleLdapAuthenticator.login_format = '%s@domain.com'
#    SimpleLdapAuthenticator.logger = RAILS_DEFAULT_LOGGER
#    class LoginController < ApplicationController 
#      def login
#        return redirect_to(:action=>'try_again') unless SimpleLdapAuthenticator.valid?(params[:username], params[:password])
#        session[:username] = params[:username]
#      end
#    end
class SimpleLdapAuthenticator
  class << self
    @servers = ['127.0.0.1']
    @use_ssl = false
    @login_format = '%s'
    attr_accessor :servers, :use_ssl, :port, :login_format, :logger, :connection, :ldap_library
    
    # Load the required LDAP library, either 'ldap' or 'net/ldap'
    def load_ldap_library
      return if @ldap_library_loaded
      if ldap_library
        if ldap_library == 'net/ldap'
          require 'net/ldap'
        else
          require 'ldap'
          require 'ldap/control'
        end
      else
        begin
          require 'ldap'
          require 'ldap/control'
          ldap_library = 'ldap'
        rescue LoadError
          require 'net/ldap'
          ldap_library = 'net/ldap'
        end
      end
      @ldap_library_loaded = true
    end
    
    # The next LDAP server to which to connect
    def server
      servers[0]
    end
    
    # The connection to the LDAP server.  A single connection is made and the
    # connection is only changed if a server returns an error other than 
    # invalid password.
    def connection
      return @connection if @connection
      load_ldap_library
      @connection = if ldap_library == 'net/ldap'
        Net::LDAP.new(:host=>server, :port=>(port), :encryption=>(:simple_tls if use_ssl))
      else
        (use_ssl ? LDAP::SSLConn : LDAP::Conn).new(server, port)
      end
    end
    
    # The port to use.  Defaults to 389 for LDAP and 636 for LDAPS.
    def port
      @port ||= use_ssl ? 636 : 389
    end
    
    # Disconnect from current LDAP server and use a different LDAP server on the
    # next authentication attempt
    def switch_server
      self.connection = nil
      servers << servers.shift
    end
    
    # Check the validity of a login/password combination
    def valid?(login, password)
      if ldap_library == 'net/ldap'
        connection.authenticate(login_format % login.to_s, password.to_s)
        begin
          if connection.bind
              logger.info("Authenticated #{login.to_s} by #{server}") if logger
              true
            else
              logger.info("Error attempting to authenticate #{login.to_s} by #{server}: #{connection.get_operation_result.code} #{connection.get_operation_result.message}") if logger
              switch_server unless connection.get_operation_result.code == 49
              false
            end
        rescue Net::LDAP::LdapError => error
          logger.info("Error attempting to authenticate #{login.to_s} by #{server}: #{error.message}") if logger
          switch_server
          false
        end
      else
        connection.unbind if connection.bound?
        begin
          connection.bind(login_format % login.to_s, password.to_s)
          connection.unbind
          logger.info("Authenticated #{login.to_s} by #{server}") if logger
          true
        rescue LDAP::ResultError => error
          connection.unbind if connection.bound?
          logger.info("Error attempting to authenticate #{login.to_s} by #{server}: #{error.message}") if logger
          switch_server unless error.message == 'Invalid credentials'
          false
        end
      end
    end
  end
end
