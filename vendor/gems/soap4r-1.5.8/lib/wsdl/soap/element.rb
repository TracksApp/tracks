# WSDL4R - XMLSchema element definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/xmlSchema/element'


module WSDL
module XMLSchema


class Element < Info
  def map_as_array?
    # parent sequence / choice may be marked as maxOccurs="unbounded"
    maxoccurs.nil? or maxoccurs != 1 or (parent and parent.map_as_array?)
  end

  def anonymous_type?
    !@ref and @name and @local_complextype
  end

  def attributes
    @local_complextype.attributes
  end
end


end
end
