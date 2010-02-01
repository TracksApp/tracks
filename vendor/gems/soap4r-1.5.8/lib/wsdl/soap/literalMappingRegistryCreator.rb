# WSDL4R - Creating LiteralMappingRegistry code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreatorSupport'


module WSDL
module SOAP


class LiteralMappingRegistryCreator
  include MappingRegistryCreatorSupport

  def initialize(definitions, name_creator, modulepath, defined_const)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
    @elements = definitions.collect_elements
    @elements.uniq!
    @attributes = definitions.collect_attributes
    @attributes.uniq!
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
    str = dump_element
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    str = dump_attribute
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    result
  end

private

  def dump_element
    @elements.collect { |ele|
      # has the definition different from the complexType of the same name
      next if ele.type.nil? and @complextypes[ele.name]
      dump_with_inner {
        if typedef = ele.local_complextype
          dump_complextypedef(@modulepath, ele.name, typedef)
        elsif typedef = ele.local_simpletype
          dump_simpletypedef(@modulepath, ele.name, typedef)
        elsif ele.type
          if typedef = @complextypes[ele.type]
            dump_complextypedef(@modulepath, ele.type, typedef, ele.name)
          elsif typedef = @simpletypes[ele.type]
            dump_simpletypedef(@modulepath, ele.type, typedef, ele.name)
          end
        end
      }
    }.compact.join("\n")
  end

  def dump_attribute
    @attributes.collect { |attr|
      if attr.local_simpletype
        dump_with_inner {
          dump_simpletypedef(@modulepath, attr.name, attr.local_simpletype)
        }
      end
    }.compact.join("\n")
  end

  def dump_simpletype
    @simpletypes.collect { |type|
      dump_with_inner {
        dump_simpletypedef(@modulepath, type.name, type)
      }
    }.compact.join("\n")
  end

  def dump_complextype
    @complextypes.collect { |type|
      unless type.abstract
        dump_with_inner {
          dump_complextypedef(@modulepath, type.name, type)
        }
      end
    }.compact.join("\n")
  end
end


end
end
