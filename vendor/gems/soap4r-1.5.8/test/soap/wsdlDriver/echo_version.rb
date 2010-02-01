require 'xsd/qname'

# {urn:example.com:simpletype-rpc-type}version_struct
class Version_struct
  @@schema_type = "version_struct"
  @@schema_ns = "urn:example.com:simpletype-rpc-type"
  @@schema_element = [
    ["myversion", ["SOAP::SOAPString", XSD::QName.new(nil, "myversion")]],
    ["msg", ["SOAP::SOAPString", XSD::QName.new(nil, "msg")]]
  ]

  attr_accessor :myversion
  attr_accessor :msg

  def initialize(myversion = nil, msg = nil)
    @myversion = myversion
    @msg = msg
  end
end

# {urn:example.com:simpletype-rpc-type}myversions
class Myversions < ::String
  @@schema_type = "myversions"
  @@schema_ns = "urn:example.com:simpletype-rpc-type"

  C_16 = Myversions.new("1.6")
  C_18 = Myversions.new("1.8")
  C_19 = Myversions.new("1.9")
end
