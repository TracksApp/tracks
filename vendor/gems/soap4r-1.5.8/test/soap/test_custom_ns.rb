require 'test/unit'
require 'soap/processor'


module SOAP


class TestCustomNs < Test::Unit::TestCase
  NORMAL_XML = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Header>
      <n1:headeritem xmlns:n1="my:foo">hi</n1:headeritem>
  </env:Header>
  <env:Body>
    <n2:test xmlns:n2="my:foo"
        xmlns:n3="my:bar"
        n3:baz="qux">bi</n2:test>
  </env:Body>
</env:Envelope>
__XML__

  CUSTOM_NS_XML = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:myns="my:foo"
    xmlns:ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <ENV:Header>
      <myns:headeritem>hi</myns:headeritem>
  </ENV:Header>
  <ENV:Body>
    <myns:test xmlns:bar="my:bar"
        bar:baz="qux">bi</myns:test>
  </ENV:Body>
</ENV:Envelope>
__XML__

  XML_WITH_DEFAULT_NS = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Header>
      <headeritem xmlns="my:foo">hi</headeritem>
  </env:Header>
  <env:Body>
    <test xmlns:n1="my:bar"
        xmlns:n2="my:foo"
        n1:baz="qux"
        n2:quxx="quxxx"
        xmlns="my:foo">bi</test>
  </env:Body>
</env:Envelope>
__XML__

  def test_custom_ns
    # create test env
    header = SOAP::SOAPHeader.new()
    hi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "headeritem"), 'hi')
    header.add("test", hi)
    body = SOAP::SOAPBody.new()
    bi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"), 'bi')
    bi.extraattr[XSD::QName.new('my:bar', 'baz')] = 'qux'
    body.add("test", bi)
    env = SOAP::SOAPEnvelope.new(header, body)
    # normal
    opt = {}
    result = SOAP::Processor.marshal(env, opt)
    assert_equal(NORMAL_XML, result)
    # Envelope ns customize
    env = SOAP::SOAPEnvelope.new(header, body)
    ns = XSD::NS.new
    ns.assign(SOAP::EnvelopeNamespace, 'ENV')
    ns.assign('my:foo', 'myns')
    # tag customize
    tag = XSD::NS.new
    tag.assign('my:bar', 'bar')
    opt = { :default_ns => ns, :default_ns_tag => tag }
    result = SOAP::Processor.marshal(env, opt)
    assert_equal(CUSTOM_NS_XML, result)
  end

  def test_default_namespace
    # create test env
    header = SOAP::SOAPHeader.new()
    hi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "headeritem"), 'hi')
    header.add("test", hi)
    body = SOAP::SOAPBody.new()
    bi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"), 'bi')
    bi.extraattr[XSD::QName.new('my:bar', 'baz')] = 'qux'
    bi.extraattr[XSD::QName.new('my:foo', 'quxx')] = 'quxxx'
    body.add("test", bi)
    env = SOAP::SOAPEnvelope.new(header, body)
    # normal
    opt = {:use_default_namespace => true}
    result = SOAP::Processor.marshal(env, opt)
    assert_equal(XML_WITH_DEFAULT_NS, result)
  end
end


end
