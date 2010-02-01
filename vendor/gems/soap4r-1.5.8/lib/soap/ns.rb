# SOAP4R - SOAP Namespace library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/datatypes'
require 'xsd/ns'
require 'soap/soap'


module SOAP


class NS < XSD::NS
  KNOWN_TAG = XSD::NS::KNOWN_TAG.dup.update(
    SOAP::EnvelopeNamespace => 'env'
  )

  def initialize(tag2ns = nil)
    super(tag2ns)
  end

private

  def default_known_tag
    KNOWN_TAG
  end
end


end
