require 'test/unit'
require 'soap/marshal'


module SOAP; module Case

# {urn:TruckMateTypes}TTMHeader
class TTMHeader
  @@schema_type = "TTMHeader"
  @@schema_ns = "urn:TruckMateTypes"
  @@schema_element = [
    ["dSN", ["SOAP::SOAPString", XSD::QName.new(nil, "DSN")]],
    ["password", ["SOAP::SOAPString", XSD::QName.new(nil, "Password")]],
    ["schema", ["SOAP::SOAPString", XSD::QName.new(nil, "Schema")]],
    ["username", ["SOAP::SOAPString", XSD::QName.new(nil, "Username")]]
  ]

  attr_accessor :dSN
  attr_accessor :password
  attr_accessor :schema
  attr_accessor :username

  def initialize(dSN = nil, password = nil, schema = nil, username = nil)
    @dSN = dSN
    @password = password
    @schema = schema
    @username = username
  end
end


class TestMapping < Test::Unit::TestCase
  def test_mapping
    dump = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <SOAP..Case..TTMHeader xmlns:n1="urn:TruckMateTypes"
        xsi:type="n1:TTMHeader"
        env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <DSN xsi:type="xsd:string">dsn</DSN>
      <Password xsi:type="xsd:string">password</Password>
      <Schema xsi:type="xsd:string">schema</Schema>
      <Username xsi:type="xsd:string">username</Username>
    </SOAP..Case..TTMHeader>
  </env:Body>
</env:Envelope>
__XML__
    o = TTMHeader.new("dsn", "password", "schema", "username")
    assert_equal(dump, SOAP::Marshal.dump(o))
  end
end


end; end
