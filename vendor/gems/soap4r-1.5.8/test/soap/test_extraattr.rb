require 'test/unit'
require 'soap/processor'


module SOAP


class TestExtrAttr < Test::Unit::TestCase

  HEADER_XML = %q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    Id="extraattr"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Header Id="extraattr">
      <n1:headeritem xmlns:n1="my:foo"
          Id="extraattr"></n1:headeritem>
  </env:Header>
  <env:Body Id="extraattr&lt;&gt;">
    <n2:test xmlns:n2="my:foo"
        Id="extraattr"></n2:test>
  </env:Body>
</env:Envelope>]

  def test_extraattr
    header = SOAP::SOAPHeader.new()
    header.extraattr["Id"] = "extraattr"
    hi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "headeritem"))
    hi.extraattr["Id"] = "extraattr"
    header.add("test", hi)
    body = SOAP::SOAPBody.new()
    body.extraattr["Id"] = "extraattr<>"
    bi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"))
    bi.extraattr["Id"] = "extraattr"
    body.add("test", bi)
    env = SOAP::SOAPEnvelope.new(header, body)
    env.extraattr["Id"] = "extraattr"
    g = SOAP::Generator.new()
    xml = g.generate(env)
    assert_equal(HEADER_XML, xml)
    #
    parser = SOAP::Parser.new
    env = parser.parse(xml)
    header = env.header
    body = env.body
    assert_equal("extraattr", env.extraattr[XSD::QName.new(nil, "Id")])
    assert_equal("extraattr", header.extraattr[XSD::QName.new(nil, "Id")])
    assert_equal("extraattr<>", body.extraattr[XSD::QName.new(nil, "Id")])
    assert_equal("extraattr", header["headeritem"].element.extraattr[XSD::QName.new(nil, "Id")])
  end
end


end
