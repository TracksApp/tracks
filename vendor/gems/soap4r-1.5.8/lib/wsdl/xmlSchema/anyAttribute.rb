# WSDL4R - XMLSchema anyAttribute definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module XMLSchema


class AnyAttribute < Info
  attr_accessor :namespace
  attr_accessor :processcontents

  def initialize
    super()
    @namespace = '##any'
    @processcontents = 'strict'
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    nil
  end

  def parse_attr(attr, value)
    case attr
    when NamespaceAttrName
      @namespace = value.source
    when ProcessContentsAttrName
      @processcontents = value.source
    else
      nil
    end
  end
end


end
end
