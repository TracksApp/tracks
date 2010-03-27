# WSDL4R - XMLSchema list definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module XMLSchema


class List < Info
  attr_reader :itemtype
  attr_reader :local_simpletype

  def initialize
    super()
    @itemtype = nil
    @local_simpletype = nil
  end

  def parse_element(element)
    case element
    when SimpleTypeName
      @local_simpletype = SimpleType.new
      @local_simpletype
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when ItemTypeAttrName
      @itemtype = value
    else
      nil
    end
  end
end


end
end
