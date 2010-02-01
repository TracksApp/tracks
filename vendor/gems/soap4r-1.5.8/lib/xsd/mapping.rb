# XSD4R - XML Mapping for Ruby
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require "soap/parser"
require 'soap/encodingstyle/literalHandler'
require "soap/generator"
require "soap/mapping"
require "soap/mapping/wsdlliteralregistry"


module XSD


module Mapping
  MappingRegistry = SOAP::Mapping::LiteralRegistry.new

  def self.obj2xml(obj, elename = nil, io = nil)
    Mapper.new(MappingRegistry).obj2xml(obj, elename, io)
  end

  def self.xml2obj(stream, klass = nil)
    Mapper.new(MappingRegistry).xml2obj(stream, klass)
  end

  class Mapper
    MAPPING_OPT = {
      :default_encodingstyle => SOAP::LiteralNamespace,
      :root_type_hint => true
    }.freeze

    def initialize(registry)
      @registry = registry
    end

    def obj2xml(obj, elename = nil, io = nil)
      opt = MAPPING_OPT.dup
      unless elename
        if definition = @registry.elename_schema_definition_from_class(obj.class)
          elename = definition.elename
          opt[:root_type_hint] = false
        end
      end
      elename = SOAP::Mapping.to_qname(elename) if elename
      soap = SOAP::Mapping.obj2soap(obj, @registry, elename, opt)
      if soap.elename.nil? or soap.elename == XSD::QName::EMPTY
        soap.elename =
          XSD::QName.new(nil, SOAP::Mapping.name2elename(obj.class.to_s))
      end
      generator = SOAP::Generator.new(opt)
      generator.generate(soap, io)
    end

    def xml2obj(stream, klass = nil)
      parser = SOAP::Parser.new(MAPPING_OPT)
      soap = parser.parse(stream)
      SOAP::Mapping.soap2obj(soap, @registry, klass)
    end
  end
end


end
