# XSD4R - XSD to ruby mapping library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/codegen/gensupport'
require 'wsdl/xmlSchema/importer'
require 'wsdl/soap/classDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/literalMappingRegistryCreator'
require 'wsdl/soap/classNameCreator'
require 'logger'


module WSDL
module XMLSchema


class XSD2Ruby
  include WSDL::SOAP::ClassDefCreatorSupport

  attr_accessor :location
  attr_reader :opt
  attr_accessor :logger
  attr_accessor :basedir

  def run
    unless @location
      raise RuntimeError, "XML Schema location not given"
    end
    @xsd = import(@location)
    @name = @opt['classdef'] || create_classname(@xsd)
    create_file
  end

private

  def initialize
    @location = nil
    @opt = {}
    @logger = Logger.new(STDERR)
    @basedir = nil
    @xsd = nil
    @name = nil
    @name_creator = WSDL::SOAP::ClassNameCreator.new
  end

  def create_file
    @modulepath = @opt['module_path']
    create_classdef if @opt.key?('classdef')
    create_mapping_registry if @opt.key?('mapping_registry')
    create_mapper if @opt.key?('mapper')
  end

  def create_classdef
    @logger.info { "Creating class definition." }
    @classdef_filename = @name + '.rb'
    check_file(@classdef_filename) or return
    write_file(@classdef_filename) do |f|
      f << WSDL::SOAP::ClassDefCreator.new(@xsd, @name_creator, @modulepath).dump
    end
  end

  def create_mapping_registry
    @logger.info { "Creating mapping registry definition." }
    @mr_filename = @name + '_mapping_registry.rb'
    check_file(@mr_filename) or return
    write_file(@mr_filename) do |f|
      f << dump_mapping_registry
    end
  end

  def create_mapper
    @logger.info { "Creating mapper definition." }
    @mapper_filename = @name + '_mapper.rb'
    check_file(@mapper_filename) or return
    write_file(@mapper_filename) do |f|
      f << dump_mapper
    end
  end

  def dump_mapping_registry
    defined_const = {}
    creator = WSDL::SOAP::LiteralMappingRegistryCreator.new(@xsd, @name_creator, @modulepath, defined_const)
    module_name = XSD::CodeGen::GenSupport.safeconstname(@name + 'MappingRegistry')
    if @modulepath
      module_name = [@modulepath, module_name].join('::')
    end
    m = XSD::CodeGen::ModuleDef.new(module_name)
    m.def_require("xsd/mapping")
    m.def_require("#{@classdef_filename}")
    varname = 'Registry'
    m.def_const(varname, '::SOAP::Mapping::LiteralRegistry.new')
    m.def_code(creator.dump(varname))
    #
    defined_const.each do |ns, tag|
      m.def_const(tag, dq(ns))
    end
    m.dump
  end

  def dump_mapper
    class_name = XSD::CodeGen::GenSupport.safeconstname(@name + 'Mapper')
    if @modulepath
      class_name = [@modulepath, class_name].join('::')
    end
    mr_name = XSD::CodeGen::GenSupport.safeconstname(@name + 'MappingRegistry')
    c = XSD::CodeGen::ClassDef.new(class_name, 'XSD::Mapping::Mapper')
    c.def_require("#{@mr_filename}")
    c.def_method("initialize") do
      "super(#{mr_name}::Registry)"
    end
    c.dump
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

  def create_classname(xsd)
    name = nil
    if xsd.targetnamespace
      name = xsd.targetnamespace.scan(/[a-zA-Z0-9]+$/)[0]
    end
    if name.nil?
      'default'
    else
      XSD::CodeGen::GenSupport.safevarname(name)
    end
  end

  def import(location)
    WSDL::XMLSchema::Importer.import(location)
  end
end


end
end


if __FILE__ == $0
  warn("WARNING: #{File.expand_path(__FILE__)} is a library file used by bin/xsd2ruby.rb.  Find bin/xsd2ruby.rb from tarball version of soap4r or install soap4r via gem.")
end
