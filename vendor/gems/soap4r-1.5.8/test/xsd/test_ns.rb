require 'test/unit'
require 'soap/marshal'


module XSD


class TestNS < Test::Unit::TestCase
  def test_xmllang
    @file = File.join(File.dirname(File.expand_path(__FILE__)), 'xmllang.xml')
    obj = SOAP::Marshal.load(File.open(@file) { |f| f.read })
    assert_equal("12345", obj.partyDataLine.gln)
    lang = obj.partyDataLine.__xmlattr[
      XSD::QName.new(XSD::NS::Namespace, "lang")]
    assert_equal("EN", lang)
  end

  def test_no_default_namespace
    env = SOAP::Processor.unmarshal(NO_DEFAULT_NAMESPACE)
    array = env.body.root_node["array"]
    item = array["item"]
    assert_equal("urn:ns", array.elename.namespace)
    assert_equal(nil, item.elename.namespace)
  end

NO_DEFAULT_NAMESPACE = <<__XML__
<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Body>
    <response xmlns="urn:ns">
      <array>
        <item attr="1" xmlns=""/>
      </array>
    </response>
  </env:Body>
</env:Envelope>
__XML__
end


end
