require 'test/unit'
require 'soap/processor'
require 'soap/mapping'
require 'soap/rpc/element'
require 'wsdl/importer'
require 'wsdl/soap/wsdl2ruby'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL
module AxisArray


class TestAxisArray < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    @xml =<<__EOX__
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
    <ns1:listItemResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="urn:jp.gr.jin.rrr.example.itemList">
      <list href="#id0"/>
    </ns1:listItemResponse>
    <multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:ItemList" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="urn:jp.gr.jin.rrr.example.itemListType">
      <Item href="#id1"/>
      <Item href="#id2"/>
      <Item href="#id3"/>
    </multiRef>
    <multiRef id="id3" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:Item" xmlns:ns3="urn:jp.gr.jin.rrr.example.itemListType" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
      <name xsi:type="xsd:string">name3</name>
    </multiRef>
    <multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns4:Item" xmlns:ns4="urn:jp.gr.jin.rrr.example.itemListType" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
      <name xsi:type="xsd:string">name1</name>
    </multiRef>
    <multiRef id="id2" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns5:Item" xmlns:ns5="urn:jp.gr.jin.rrr.example.itemListType" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
      <name xsi:type="xsd:string">name2</name>
    </multiRef>
  </soapenv:Body>
</soapenv:Envelope>
__EOX__
    setup_classdef
  end

  def teardown
    unless $DEBUG
      File.unlink(pathname('itemList.rb'))
      File.unlink(pathname('itemListMappingRegistry.rb'))
      File.unlink(pathname('itemListDriver.rb'))
    end
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("axisArray.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'itemListDriver.rb', 'itemList.rb', 'itemListMappingRegistry.rb')
  end

  def test_by_stub
    driver = ItemListPortType.new
    driver.test_loopback_response << @xml
    ary = driver.listItem
    assert_equal(3, ary.size)
    assert_equal("name1", ary[0].name)
    assert_equal("name2", ary[1].name)
    assert_equal("name3", ary[2].name)
  end

  def test_by_wsdl
    wsdlfile = File.join(File.dirname(File.expand_path(__FILE__)), 'axisArray.wsdl')
    wsdl = WSDL::Importer.import(wsdlfile)
    service = wsdl.services[0]
    port = service.ports[0]
    wsdl_types = wsdl.collect_complextypes
    rpc_decode_typemap = wsdl_types + wsdl.soap_rpc_complextypes(port.find_binding)
    opt = {}
    opt[:default_encodingstyle] = ::SOAP::EncodingNamespace
    opt[:decode_typemap] = rpc_decode_typemap
    header, body = ::SOAP::Processor.unmarshal(@xml, opt)
    ary = ::SOAP::Mapping.soap2obj(body.response)
    assert_equal(3, ary.size)
    assert_equal("name1", ary[0].name)
    assert_equal("name2", ary[1].name)
    assert_equal("name3", ary[2].name)
  end

XML_LONG = <<__XML__
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
    <ns1:getMeetingInfoResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="urn:jp.gr.jin.rrr.example.itemList">
      <getMeetingInfoReturn href="#id0"/>
    </ns1:getMeetingInfoResponse>
    <multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:MeetingInfo" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="urn:long">
      <meetingId href="#id11"/>
    </multiRef>
    <multiRef id="id11" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="xsd:long" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">105759347</multiRef>
  </soapenv:Body>
</soapenv:Envelope>
__XML__

  def test_multiref_long
    driver = ItemListPortType.new
    driver.test_loopback_response << XML_LONG
    ret = driver.getMeetingInfo
    assert_equal(105759347, ret.meetingId)
  end

  def pathname(filename)
    File.join(DIR, filename)
  end
end


end
end
