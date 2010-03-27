# WSDL4R - XMLSchema import definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/xmlSchema/importer'
require 'wsdl/xmlSchema/importHandler'


module WSDL
module XMLSchema


class Import < Info
  attr_reader :namespace

  def initialize
    super
    @namespace = nil
    @handler = ImportHandler.new
  end

  def schemalocation
    @handler.schemalocation
  end

  def content
    @handler.content
  end

  def parse_element(element)
    nil
  end

  def parse_attr(attr, value)
    case attr
    when NamespaceAttrName
      @namespace = value.source
    when SchemaLocationAttrName
      @handler.parse_schemalocation(value.source, root, parent)
    else
      nil
    end
  end
end


end
end
