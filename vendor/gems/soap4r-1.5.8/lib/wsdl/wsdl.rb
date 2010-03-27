# WSDL4R - Base definitions.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/qname'
require 'soap/nestedexception'


module WSDL


Version = '0.0.2'

Namespace = 'http://schemas.xmlsoap.org/wsdl/'
SOAPBindingNamespace ='http://schemas.xmlsoap.org/wsdl/soap/'

class Error < StandardError; include ::SOAP::NestedException; end


end
