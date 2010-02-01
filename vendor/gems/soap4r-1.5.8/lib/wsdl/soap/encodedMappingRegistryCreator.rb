# WSDL4R - Creating EncodedMappingRegistry code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreatorSupport'


module WSDL
module SOAP


class EncodedMappingRegistryCreator
  include MappingRegistryCreatorSupport

  attr_reader :definitions

  def initialize(definitions, name_creator, modulepath, defined_const)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
    @simpletypes = definitions.collect_simpletypes
    @simpletypes.uniq!
    @complextypes = definitions.collect_complextypes
    @complextypes.uniq!
    @varname = nil
    @defined_const = defined_const
  end

  def dump(varname)
    @varname = varname
    result = ''
    str = dump_complextype
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    str = dump_simpletype
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    result
  end

private

  def dump_complextype
    @complextypes.collect { |type|
      unless type.abstract
        dump_with_inner {
          dump_complextypedef(@modulepath, type.name, type, nil, :encoded => true)
        }
      end
    }.compact.join("\n")
  end

  def dump_simpletype
    @simpletypes.collect { |type|
      dump_with_inner {
        dump_simpletypedef(@modulepath, type.name, type, nil, :encoded => true)
      }
    }.compact.join("\n")
  end
end


end
end
