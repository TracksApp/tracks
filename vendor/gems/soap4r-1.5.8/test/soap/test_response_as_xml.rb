require 'test/unit'
require 'soap/rpc/httpserver'
require 'soap/rpc/driver'
require 'rexml/document'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'testutil.rb')


module SOAP


class TestResponseAsXml < Test::Unit::TestCase
  Namespace = "urn:example.com:hello"
  class Server < ::SOAP::RPC::HTTPServer
    def on_init
      add_method(self, 'hello', 'name')
    end

    def hello(name)
      "hello #{name}"
    end
  end

  Port = 17171

  def setup
    setup_server
    setup_client
  end

  def setup_server
    @server = Server.new(
      :Port => Port,
      :BindAddress => "0.0.0.0",
      :AccessLog => [],
      :SOAPDefaultNamespace => Namespace
    )
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_client
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/", Namespace)
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method('hello', 'name')
    @client.add_document_method('hellodoc', Namespace, XSD::QName.new(Namespace, 'helloRequest'), XSD::QName.new(Namespace, 'helloResponse'))
  end

  def teardown
    teardown_server if @server
    teardown_client if @client
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def teardown_client
    @client.reset_stream
  end

  RESPONSE_AS_XML=<<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:helloResponse xmlns:n1="urn:example.com:hello"
        env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return xsi:type="xsd:string">hello world</return>
    </n1:helloResponse>
  </env:Body>
</env:Envelope>
__XML__

  def test_hello
    assert_equal("hello world", @client.hello("world"))
    @client.return_response_as_xml = true
    xml = @client.hello("world")
    assert_equal(RESPONSE_AS_XML, xml, [RESPONSE_AS_XML, xml].join("\n\n"))
    doc = REXML::Document.new(@client.hello("world"))
    assert_equal("hello world",
      REXML::XPath.match(doc, "//*[name()='return']")[0].text)
  end

  RESPONSE_CDATA = <<__XML__.chomp
<env:Envelope xmlns:env='http://schemas.xmlsoap.org/soap/envelope/'>
  <env:Body>
    <gno:helloResponse xmlns:gno='urn:example.com:hello'>
      <gno:htmlContent>
        <![CDATA[<span>some html</span>]]>
      </gno:htmlContent>
    </gno:helloResponse>
  </env:Body>
</env:Envelope>
__XML__
  def test_cdata
    @client.return_response_as_xml = false
    @client.test_loopback_response << RESPONSE_CDATA
    ret = @client.hellodoc(nil)
    assert_equal("\n        <span>some html</span>\n      ", ret.htmlContent)
    #
    @client.return_response_as_xml = true
    @client.test_loopback_response << RESPONSE_CDATA
    xml = @client.hello(nil)
    assert_equal(RESPONSE_CDATA, xml)
    require 'rexml/document'
    doc = REXML::Document.new(xml)
    assert_equal("<span>some html</span>",
      REXML::XPath.match(doc, "//*[name()='gno:htmlContent']")[0][1].value)
    #
  end
end


end
