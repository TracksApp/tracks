require 'test/unit'
require 'soap/rpc/standaloneServer'
require 'soap/rpc/driver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module SOAP; module ASPDotNet


class TestASPDotNet < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = "http://localhost/WebService/"

    def on_init
      add_document_method(
        self,
        Namespace + 'SayHello',
        'sayHello',
        XSD::QName.new(Namespace, 'SayHello'),
        XSD::QName.new(Namespace, 'SayHelloResponse')
      )
    end

    def sayHello(arg)
      name = arg['name']
      "Hello #{name}"
    end
  end

  Port = 17171
  Endpoint = "http://localhost:#{Port}/"

  def setup
    setup_server
    @client = nil
  end

  def teardown
    teardown_server if @server
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def test_document_method
    @client = SOAP::RPC::Driver.new(Endpoint, Server::Namespace)
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.add_document_method('sayHello', Server::Namespace + 'SayHello',
      XSD::QName.new(Server::Namespace, 'SayHello'),
      XSD::QName.new(Server::Namespace, 'SayHelloResponse'))
    assert_equal("Hello Mike", @client.sayHello(:name => "Mike"))
  end

  def test_xml
    @client = SOAP::RPC::Driver.new(Endpoint, Server::Namespace)
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.add_document_method('sayHello', Server::Namespace + 'SayHello',
      XSD::QName.new(Server::Namespace, 'SayHello'),
      XSD::QName.new(Server::Namespace, 'SayHelloResponse'))
    require 'rexml/document'
    xml = <<__XML__
<n1:sayHello xmlns:n1="http://localhost/WebService/">
  <n1:name>Mike</n1:name>
</n1:sayHello>
__XML__
    ele = REXML::Document.new(xml)
    assert_equal("Hello Mike", @client.sayHello(ele))
    def xml.to_xmlpart; to_s; end
    assert_equal("Hello Mike", @client.sayHello(xml))
  end

  def test_aspdotnethandler
    @client = SOAP::RPC::Driver.new(Endpoint, Server::Namespace)
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.add_method_with_soapaction('sayHello', Server::Namespace + 'SayHello', 'name')
    @client.default_encodingstyle = SOAP::EncodingStyle::ASPDotNetHandler::Namespace
    assert_equal("Hello Mike", @client.sayHello("Mike"))
  end

  if defined?(HTTPClient)

    # qualified!
    REQUEST_ASPDOTNETHANDLER =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:sayHello xmlns:n1="http://localhost/WebService/">
      <n1:name>Mike</n1:name>
    </n1:sayHello>
  </env:Body>
</env:Envelope>]

    def test_aspdotnethandler_envelope
      @client = SOAP::RPC::Driver.new(Endpoint, Server::Namespace)
      @client.wiredump_dev = str = ''
      @client.add_method_with_soapaction('sayHello', Server::Namespace + 'SayHello', 'name')
      @client.default_encodingstyle = SOAP::EncodingStyle::ASPDotNetHandler::Namespace
      assert_equal("Hello Mike", @client.sayHello("Mike"))
      assert_equal(REQUEST_ASPDOTNETHANDLER, parse_requestxml(str),
        [REQUEST_ASPDOTNETHANDLER, parse_requestxml(str)].join("\n\n"))
    end

    def parse_requestxml(str)
      str.split(/\r?\n\r?\n/)[3]
    end

  end
end


end; end
