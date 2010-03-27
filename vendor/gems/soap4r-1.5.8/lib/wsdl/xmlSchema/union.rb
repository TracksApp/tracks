# WSDL4R - XMLSchema union definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class Union < Info
  attr_reader :member_types

  def initialize
    super
    @member_types = nil
  end

  def parse_attr(attr, value)
    case attr
    when MemberTypesAttrName
      @member_types = value.source
    end
  end
end


end
end
