require "#{File.dirname(__FILE__)}/../test_helper"
require 'tempfile'

module Tracks
  class Config
    def self.salt
      "change-me"
    end
    def self.auth_schemes
      ['database','ldap']
    end
  end
end

class LdapAuthTest < ActionController::IntegrationTest

  fixtures :users
  
  RUN_LDAP_TESTS = ENV['RUN_TRACKS_LDAP_TESTS'] || false
  SLAPD_BIN = "/usr/libexec/slapd" #You may need to adjust this
  SLAPD_SCHEMA_DIR = "/etc/openldap/schema/" #You may need to adjust this
  SLAPD_TEST_PORT = 10389
  OUTPUT_DEBUG_INFO = false

  begin
    require 'net/ldap' #requires ruby-net-ldap gem be installed
    require 'simple_ldap_authenticator'
  end if RUN_LDAP_TESTS

  SimpleLdapAuthenticator.ldap_library = 'net/ldap'
  SimpleLdapAuthenticator.servers = %w'localhost'
  SimpleLdapAuthenticator.use_ssl = false
  SimpleLdapAuthenticator.login_format = 'cn=%s,dc=lukemelia,dc=com'
  SimpleLdapAuthenticator.port = 10389
  SimpleLdapAuthenticator.logger = RAILS_DEFAULT_LOGGER
  
  def setup
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt

    if RUN_LDAP_TESTS
      setup_ldap_server_conf
      start_ldap_server
    end
  end
  
  def teardown
    stop_ldap_server if RUN_LDAP_TESTS
  end
    
  def test_authenticate_against_ldap
   add_ldap_user_to_ldap_repository
   assert SimpleLdapAuthenticator.valid?('john', 'deere')
   user = User.authenticate('john', 'deere')
   assert_not_nil(user)
   assert_equal user.login, 'john'
  end

  private :test_authenticate_against_ldap unless RUN_LDAP_TESTS 
  
  def setup_ldap_server_conf
    @slapd_conf = create_slapd_conf()
    open(@slapd_conf.path) { |f| f.read }
    unless File.exist?(SLAPD_BIN)
      assert false, "slapd could not be found at #{SLAPD_BIN}. Adjust the path in #{__FILE__}"
    end
  end

  def start_ldap_server
    t = Thread.new(@slapd_conf.path) do |slapd_conf_path|
      puts "starting slapd..." if OUTPUT_DEBUG_INFO
      run_cmd %Q{/usr/libexec/slapd -f #{slapd_conf_path} -h "ldap://127.0.0.1:10389/" -d0}
    end
    sleep(2)
    run_cmd %Q{ldapsearch -H "ldap://127.0.0.1:10389/" -x -b '' -s base '(objectclass=*)' namingContexts}
  end
  
  def add_ldap_user_to_ldap_repository
    ldif_file = create_ldif()
    run_cmd %Q{ldapadd -H "ldap://127.0.0.1:10389/" -f #{ldif_file.path} -cxv -D "cn=Manager,dc=lukemelia,dc=com" -w secret}
    puts `cat #{ldif_file.path}` if OUTPUT_DEBUG_INFO
  end
  
  def stop_ldap_server
    pid = open(get_pid_file_path(@slapd_conf)) { |f| f.read }
    run_cmd "kill -TERM #{pid}"
  end
  
  def create_slapd_conf
    slapd_conf = Tempfile.new("slapd.conf")
    slapd_conf.path
    data_dir = slapd_conf.path + '-data'
    pid_file = get_pid_file_path(slapd_conf)
    Dir.mkdir(data_dir)
    encrypted_password = `slappasswd -s secret`
    open(slapd_conf.path, 'w') do |f| 
      f.puts %Q{include #{SLAPD_SCHEMA_DIR}core.schema
pidfile #{pid_file}
database ldbm
suffix "dc=lukemelia,dc=com"
rootdn "cn=Manager,dc=lukemelia,dc=com"
rootpw #{encrypted_password}
directory #{data_dir}

access to *
  by self write
  by users read
  by anonymous auth
}
    end
    puts `cat #{slapd_conf.path}` if OUTPUT_DEBUG_INFO
    slapd_conf
  end

  def create_ldif
    ldif_file = Tempfile.new("ldap_user.ldif")
    encrypted_password = `slappasswd -s deere`
    open(ldif_file.path, 'w') do |f| 
          f.puts %Q{dn: dc=lukemelia,dc=com
objectclass: dcObject
objectclass: organization
o: Luke Melia DotCom
dc: lukemelia

dn: cn=john,dc=lukemelia,dc=com
cn: john
sn: john
objectclass: person
userPassword: #{encrypted_password}
}
        end
    ldif_file
  end
  
  def run_cmd(cmd)
    puts cmd if OUTPUT_DEBUG_INFO
    cmd_out = `#{cmd}`
    puts cmd_out if OUTPUT_DEBUG_INFO
  end
  
  def get_pid_file_path(tempfile)
    tempfile.path + '.pid'
  end

end
