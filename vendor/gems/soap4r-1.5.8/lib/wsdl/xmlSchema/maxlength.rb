# WSDL4R - XMLSchema maxLength definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module XMLSchema


class MaxLength < Info
  def initialize
    super
  end

  def parse_element(element)
    nil
  end

  def parse_attr(attr, value)
    case attr
    when FixedAttrName
      parent.fixed[:maxlength] = to_boolean(value)
    when ValueAttrName
      parent.maxlength = to_int(value)
    end
  end
end


end
end
