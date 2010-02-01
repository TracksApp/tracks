#!/usr/bin/env ruby

require 'getoptlong'
require 'logger'
require 'wsdl/soap/wsdl2ruby'


class WSDL2RubyApp < Logger::Application
private

  OptSet = [
    ['--wsdl','-w', GetoptLong::REQUIRED_ARGUMENT],
    ['--module_path','-m', GetoptLong::REQUIRED_ARGUMENT],
    ['--type','-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--classdef','-e', GetoptLong::OPTIONAL_ARGUMENT],
    ['--mapping_registry','-r', GetoptLong::NO_ARGUMENT],
    ['--client_skelton','-c', GetoptLong::OPTIONAL_ARGUMENT],
    ['--servant_skelton','-s', GetoptLong::OPTIONAL_ARGUMENT],
    ['--cgi_stub','-g', GetoptLong::OPTIONAL_ARGUMENT],
    ['--servlet_stub','-l', GetoptLong::OPTIONAL_ARGUMENT],
    ['--standalone_server_stub','-a', GetoptLong::OPTIONAL_ARGUMENT],
    ['--driver','-d', GetoptLong::OPTIONAL_ARGUMENT],
    ['--drivername_postfix','-n', GetoptLong::REQUIRED_ARGUMENT],
    ['--force','-f', GetoptLong::NO_ARGUMENT],
    ['--quiet','-q', GetoptLong::NO_ARGUMENT],
  ]

  def initialize
    super('app')
    STDERR.sync = true
    self.level = Logger::FATAL
  end

  def run
    @worker = WSDL::SOAP::WSDL2Ruby.new
    @worker.logger = @log
    location, opt = parse_opt(GetoptLong.new(*OptSet))
    usage_exit unless location
    @worker.location = location
    if opt['quiet']
      self.level = Logger::FATAL
    else
      self.level = Logger::INFO
    end
    @worker.opt.update(opt)
    @worker.run
    0
  end

  def usage_exit
    puts <<__EOU__
Usage: #{ $0 } --wsdl wsdl_location [options]
  wsdl_location: filename or URL

Example:
  For server side:
    #{ $0 } --wsdl myapp.wsdl --type server
  For client side:
    #{ $0 } --wsdl myapp.wsdl --type client

Options:
  --wsdl wsdl_location
  --type server|client
    --type server implies;
	--classdef --mapping_registry --servant_skelton --standalone_server_stub
    --type client implies;
	--classdef --mapping_registry --client_skelton --driver
  --classdef [filenameprefix]
  --mapping_registry
  --client_skelton [servicename]
  --servant_skelton [porttypename]
  --cgi_stub [servicename]
  --servlet_stub [servicename]
  --standalone_server_stub [servicename]
  --driver [porttypename]
  --drivername_postfix driver_classname_postfix
  --module_path Module::Path::Name
  --force
  --quiet

Terminology:
  Client <-> Driver <-(SOAP)-> Stub <-> Servant

  Driver and Stub: Automatically generated
  Client and Servant: Skelton generated (you should change)
__EOU__
    exit 1
  end

  def parse_opt(getoptlong)
    opt = {}
    wsdl = nil
    begin
      getoptlong.each do |name, arg|
	case name
	when "--wsdl"
	  wsdl = arg
        when "--module_path"
          opt['module_path'] = arg
	when "--type"
	  case arg
	  when "server"
	    opt['classdef'] ||= nil
	    opt['mapping_registry'] ||= nil
	    opt['servant_skelton'] ||= nil
	    opt['standalone_server_stub'] ||= nil
	  when "client"
	    opt['classdef'] ||= nil
	    opt['mapping_registry'] ||= nil
	    opt['driver'] ||= nil
	    opt['client_skelton'] ||= nil
	  else
	    raise ArgumentError.new("Unknown type #{ arg }")
	  end
	when "--classdef", "--mapping_registry",
            "--client_skelton", "--servant_skelton",
            "--cgi_stub", "--servlet_stub", "--standalone_server_stub",
            "--driver"
	  opt[name.sub(/^--/, '')] = arg.empty? ? nil : arg
        when "--drivername_postfix"
          opt['drivername_postfix'] = arg
	when "--force"
	  opt['force'] = true
        when "--quiet"
          opt['quiet'] = true
	else
	  raise ArgumentError.new("Unknown type #{ arg }")
	end
      end
    rescue
      usage_exit
    end
    return wsdl, opt
  end
end

WSDL2RubyApp.new.start
