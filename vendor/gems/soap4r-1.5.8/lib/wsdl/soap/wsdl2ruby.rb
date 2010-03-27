# WSDL4R - WSDL to ruby mapping library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'logger'
require 'xsd/qname'
require 'wsdl/importer'
require 'wsdl/soap/classDefCreator'
require 'wsdl/soap/servantSkeltonCreator'
require 'wsdl/soap/driverCreator'
require 'wsdl/soap/clientSkeltonCreator'
require 'wsdl/soap/standaloneServerStubCreator'
require 'wsdl/soap/servletStubCreator'
require 'wsdl/soap/cgiStubCreator'
require 'wsdl/soap/classNameCreator'


module WSDL
module SOAP


class WSDL2Ruby
  attr_accessor :location
  attr_reader :opt
  attr_accessor :logger
  attr_accessor :basedir

  def run
    unless @location
      raise RuntimeError, "WSDL location not given"
    end
    @wsdl = import(@location)
    if @opt['classdef']
      @name = @opt['classdef']
    else
      @name = @wsdl.name ? @wsdl.name.name : 'default'
    end
    create_file
  end

private

  def initialize
    @modulepath = nil
    @location = nil
    @opt = {}
    @logger = Logger.new(STDERR)
    @basedir = nil
    @wsdl = nil
    @name = nil
    @classdef_filename = nil
    @mr_filename = nil
    @name_creator = ClassNameCreator.new
  end

  def create_file
    @modulepath = @opt['module_path']
    create_classdef if @opt.key?('classdef')
    create_mapping_registry if @opt.key?('mapping_registry')
    create_servant_skelton(@opt['servant_skelton']) if @opt.key?('servant_skelton')
    create_cgi_stub(@opt['cgi_stub']) if @opt.key?('cgi_stub')
    create_standalone_server_stub(@opt['standalone_server_stub']) if @opt.key?('standalone_server_stub')
    create_servlet_stub(@opt['servlet_stub']) if @opt.key?('servlet_stub')
    create_driver(@opt['driver'], @opt['drivername_postfix'] || '') if @opt.key?('driver')
    create_client_skelton(@opt['client_skelton']) if @opt.key?('client_skelton')
  end

  def create_classdef
    @logger.info { "Creating class definition." }
    @classdef_filename = @name + '.rb'
    check_file(@classdef_filename) or return
    write_file(@classdef_filename) do |f|
      f << WSDL::SOAP::ClassDefCreator.new(@wsdl, @name_creator, @modulepath).dump
    end
  end

  def create_mapping_registry
    @logger.info { "Creating mapping registry definition." }
    @mr_filename = @name + 'MappingRegistry.rb'
    check_file(@mr_filename) or return
    write_file(@mr_filename) do |f|
      f << "require '#{@classdef_filename}'\n" if @classdef_filename
      f << WSDL::SOAP::MappingRegistryCreator.new(@wsdl, @name_creator, @modulepath).dump
    end
  end

  def create_client_skelton(servicename)
    return if @wsdl.services.empty?
    @logger.info { "Creating client skelton." }
    servicename ||= @wsdl.services[0].name.name
    @client_skelton_filename = servicename + 'Client.rb'
    check_file(@client_skelton_filename) or return
    write_file(@client_skelton_filename) do |f|
      f << shbang << "\n"
      f << "require '#{@driver_filename}'\n\n" if @driver_filename
      f << WSDL::SOAP::ClientSkeltonCreator.new(@wsdl, @name_creator, @modulepath).dump(create_name(servicename))
    end
  end

  def create_servant_skelton(porttypename)
    @logger.info { "Creating servant skelton." }
    @servant_skelton_filename = (porttypename || @name + 'Servant') + '.rb'
    check_file(@servant_skelton_filename) or return
    write_file(@servant_skelton_filename) do |f|
      f << "require '#{@classdef_filename}'\n\n" if @classdef_filename
      f << WSDL::SOAP::ServantSkeltonCreator.new(@wsdl, @name_creator, @modulepath).dump(create_name(porttypename))
    end
  end

  def create_cgi_stub(servicename)
    @logger.info { "Creating CGI stub." }
    servicename ||= @wsdl.services[0].name.name
    @cgi_stubFilename = servicename + '.cgi'
    check_file(@cgi_stubFilename) or return
    write_file(@cgi_stubFilename) do |f|
      f << shbang << "\n"
      f << "require '#{@servant_skelton_filename}'\n" if @servant_skelton_filename
      f << "require '#{@mr_filename}'\n" if @mr_filename
      f << WSDL::SOAP::CGIStubCreator.new(@wsdl, @name_creator, @modulepath).dump(create_name(servicename))
    end
  end

  def create_standalone_server_stub(servicename)
    @logger.info { "Creating standalone stub." }
    servicename ||= @wsdl.services[0].name.name
    @standalone_server_stub_filename = servicename + '.rb'
    check_file(@standalone_server_stub_filename) or return
    write_file(@standalone_server_stub_filename) do |f|
      f << shbang << "\n"
      f << "require '#{@servant_skelton_filename}'\n" if @servant_skelton_filename
      f << "require '#{@mr_filename}'\n" if @mr_filename
      f << WSDL::SOAP::StandaloneServerStubCreator.new(@wsdl, @name_creator, @modulepath).dump(create_name(servicename))
    end
  end

  def create_servlet_stub(servicename)
    @logger.info { "Creating servlet stub." }
    servicename ||= @wsdl.services[0].name.name
    @servlet_stub_filename = servicename + 'Servlet.rb'
    check_file(@servlet_stub_filename) or return
    write_file(@servlet_stub_filename) do |f|
      f << shbang << "\n"
      f << "require '#{@servant_skelton_filename}'\n" if @servant_skelton_filename
      f << "require '#{@mr_filename}'\n" if @mr_filename
      f << WSDL::SOAP::ServletStubCreator.new(@wsdl, @name_creator, @modulepath).dump(create_name(servicename))
    end
  end

  def create_driver(porttypename, drivername_postfix)
    @logger.info { "Creating driver." }
    @driver_filename = (porttypename || @name) + 'Driver.rb'
    creator = WSDL::SOAP::DriverCreator.new(@wsdl, @name_creator, @modulepath)
    creator.drivername_postfix = drivername_postfix
    check_file(@driver_filename) or return
    write_file(@driver_filename) do |f|
      f << "require '#{@classdef_filename}'\n" if @classdef_filename
      f << "require '#{@mr_filename}'\n" if @mr_filename
      f << creator.dump(create_name(porttypename))
    end
  end

  def write_file(filename)
    if @basedir
      filename = File.join(basedir, filename)
    end
    File.open(filename, "w") do |f|
      yield f
    end
  end

  def check_file(filename)
    if @basedir
      filename = File.join(basedir, filename)
    end
    if FileTest.exist?(filename)
      if @opt.key?('force')
	@logger.warn {
	  "File '#{filename}' exists but overrides it."
	}
	true
      else
	@logger.warn {
	  "File '#{filename}' exists.  #{$0} did not override it."
	}
	false
      end
    else
      @logger.info { "Creates file '#{filename}'." }
      true
    end
  end

  def shbang
    "#!/usr/bin/env ruby"
  end

  def create_name(name)
    name ? XSD::QName.new(@wsdl.targetnamespace, name) : nil
  end

  def import(location)
    WSDL::Importer.import(location)
  end
end


end
end


if __FILE__ == $0
  warn("WARNING: #{File.expand_path(__FILE__)} is a library file used by bin/wsdl2ruby.rb.  Find bin/wsdl2ruby.rb from tarball version of soap4r or install soap4r via gem.")
end
