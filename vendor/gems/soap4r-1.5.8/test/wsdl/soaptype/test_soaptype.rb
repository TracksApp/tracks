require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module RPC


class TestSOAPTYPE < Test::Unit::TestCase
  include ::SOAP

  class Server < ::SOAP::RPC::StandaloneServer
    include ::SOAP

    def on_init
      #self.generate_explicit_type = false
      add_rpc_method(self, 'echo_soaptype', 'arg')
    end

    def echo_soaptype(arg)
      res = Wrapper.new
      res.short = SOAPShort.new(arg.short)
      res.long = SOAPLong.new(arg.long)
      res.double = SOAPFloat.new(arg.double)
      res
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_server
    setup_classdef
    @client = nil
  end

  def teardown
    teardown_server if @server
    unless $DEBUG
      File.unlink(pathname('echo.rb'))
      File.unlink(pathname('echoMappingRegistry.rb'))
      File.unlink(pathname('echoDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:soaptype", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("soaptype.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.run
    TestUtil.require(DIR, 'echo.rb', 'echoMappingRegistry.rb', 'echoDriver.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

SOAPTYPE_WSDL_XML = %q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echo_soaptype xmlns:n1="urn:soaptype"
        env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <arg xmlns:n2="urn:soaptype-type"
          xsi:type="n2:wrapper">
        <short xsi:type="xsd:short">123</short>
        <long xsi:type="xsd:long">456</long>
        <double xsi:type="xsd:double">+789</double>
      </arg>
    </n1:echo_soaptype>
  </env:Body>
</env:Envelope>]

SOAPTYPE_NATIVE_XML = %q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echo_soaptype xmlns:n1="urn:soaptype"
        env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <arg xsi:type="xsd:anyType">
        <short xsi:type="xsd:short">123</short>
        <long xsi:type="xsd:long">456</long>
        <double xsi:type="xsd:double">+789</double>
      </arg>
    </n1:echo_soaptype>
  </env:Body>
</env:Envelope>]

  def test_wsdl
    wsdl = File.join(DIR, 'soaptype.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = str = ''

    arg = Wrapper.new
    arg.short = 123
    arg.long = 456
    arg.double = 789
    res = @client.echo_soaptype(arg)

    assert_equal(123, res.short)
    assert_equal(456, res.long)
    assert_equal(789.0, res.double)

    assert_equal(SOAPTYPE_WSDL_XML, parse_requestxml(str))
  end

  def test_stub
    @client = WSDL::RPC::Echo_port_type.new("http://localhost:#{Port}/")
    @client.wiredump_dev = str = ''

    arg = WSDL::RPC::Wrapper.new
    arg.short = 123
    arg.long = 456
    arg.double = 789
    res = @client.echo_soaptype(arg)

    assert_equal(123, res.short)
    assert_equal(456, res.long)
    assert_equal(789.0, res.double)

    assert_equal(SOAPTYPE_WSDL_XML, parse_requestxml(str))
  end

  def test_native
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/", 'urn:soaptype')
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.add_method('echo_soaptype', 'arg')
    @client.wiredump_dev = str = ''
    @client.mapping_registry = WSDL::RPC::EchoMappingRegistry::EncodedRegistry
    @client.literal_mapping_registry = WSDL::RPC::EchoMappingRegistry::LiteralRegistry

    arg = ::Struct.new(:short, :long, :double).new
    arg.short = SOAPShort.new(123)
    arg.long = SOAPLong.new(456)
    arg.double = SOAPDouble.new(789)
    res = @client.echo_soaptype(arg)

    assert_equal(123, res.short)
    assert_equal(456, res.long)
    assert_equal(789.0, res.double)

    assert_equal(SOAPTYPE_NATIVE_XML, parse_requestxml(str))
  end

  def parse_requestxml(str)
    str.split(/\r?\n\r?\n/)[3]
  end
end


end; end
