# WSDL4R - Creating MappingRegistry code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/encodedMappingRegistryCreator'
require 'wsdl/soap/literalMappingRegistryCreator'
require 'xsd/codegen/moduledef.rb'


module WSDL
module SOAP


class MappingRegistryCreator
  include ClassDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions, name_creator, modulepath = nil)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
  end

  def dump
    defined_const = {}
    encoded_creator = EncodedMappingRegistryCreator.new(@definitions, @name_creator, @modulepath, defined_const)
    literal_creator = LiteralMappingRegistryCreator.new(@definitions, @name_creator, @modulepath, defined_const)
    wsdl_name = @definitions.name ? @definitions.name.name : 'default'
    module_name = safeconstname(wsdl_name + 'MappingRegistry')
    if @modulepath
      module_name = [@modulepath, module_name].join('::')
    end
    m = XSD::CodeGen::ModuleDef.new(module_name)
    m.def_require("soap/mapping")
    varname = 'EncodedRegistry'
    m.def_const(varname, '::SOAP::Mapping::EncodedRegistry.new')
    m.def_code(encoded_creator.dump(varname))
    varname = 'LiteralRegistry'
    m.def_const(varname, '::SOAP::Mapping::LiteralRegistry.new')
    m.def_code(literal_creator.dump(varname))
    #
    defined_const.each do |ns, tag|
      m.def_const(tag, dq(ns))
    end
    m.dump
  end
end


end
end
