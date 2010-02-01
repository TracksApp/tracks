require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module Any


class TestAny < Test::Unit::TestCase
  Namespace = 'urn:example.com:echo'
  TypeNamespace = 'urn:example.com:echo-type'

  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      # use WSDL to serialize/deserialize
      wsdlfile = File.join(DIR, 'any.wsdl')
      wsdl = WSDL::Importer.import(wsdlfile)
      port = wsdl.services[0].ports[0]
      wsdl_elements = wsdl.collect_elements
      wsdl_types = wsdl.collect_complextypes + wsdl.collect_simpletypes
      rpc_decode_typemap = wsdl_types +
        wsdl.soap_rpc_complextypes(port.find_binding)
      @router.mapping_registry =
        ::SOAP::Mapping::WSDLEncodedRegistry.new(rpc_decode_typemap)
      @router.literal_mapping_registry =
        ::SOAP::Mapping::WSDLLiteralRegistry.new(wsdl_types, wsdl_elements)
      # add method
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(TypeNamespace, 'foo.bar'),
        XSD::QName.new(TypeNamespace, 'foo.bar')
      )
      add_rpc_operation(self,
        XSD::QName.new("urn:example.com:echo", "echoAny"),
        "urn:example.com:echoAny",
        "echoAny",
        [ ["retval", "echoany_return", [XSD::QName.new("http://www.w3.org/2001/XMLSchema", "anyType")]] ],
        { :request_style =>  :rpc, :request_use =>  :encoded,
          :response_style => :rpc, :response_use => :encoded,
          :faults => {} }
      )
    end

    def echo(arg)
      res = FooBar.new(arg.before, arg.after)
      res.set_any([
        ::SOAP::SOAPElement.new("foo", "bar"),
        ::SOAP::SOAPElement.new("baz", "qux")
      ])
      res
      # TODO: arg
    end

    AnyStruct = Struct.new(:a, :b)
    def echoAny
      AnyStruct.new(1, Time.mktime(2007, 1, 1))
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
      File.unlink(pathname('echo.rb')) if File.exist?(pathname('echo.rb'))
      File.unlink(pathname('echoMappingRegistry.rb')) if File.exist?(pathname('echoMappingRegistry.rb'))
      File.unlink(pathname('echoDriver.rb')) if File.exist?(pathname('echoDriver.rb'))
      File.unlink(pathname('echoServant.rb')) if File.exist?(pathname('echoServant.rb'))
      File.unlink(pathname('echo_service.rb')) if File.exist?(pathname('echo_service.rb'))
      File.unlink(pathname('echo_serviceClient.rb')) if File.exist?(pathname('echo_serviceClient.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("any.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'echoDriver.rb', 'echoMappingRegistry.rb', 'echo.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_any
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("any.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['client_skelton'] = nil
    gen.opt['servant_skelton'] = nil
    gen.opt['standalone_server_stub'] = nil
    gen.opt['force'] = true
    TestUtil.silent do
      gen.run
    end
    compare("expectedEcho.rb", "echo.rb")
    compare("expectedMappingRegistry.rb", "echoMappingRegistry.rb")
    compare("expectedDriver.rb", "echoDriver.rb")
    compare("expectedService.rb", "echo_service.rb")
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def test_anyreturl_wsdl
    wsdl = File.join(DIR, 'any.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    res = @client.echoAny
    assert_equal(1, res.a)
    assert_equal(2007, res.b.year)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'any.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = FooBar.new("before", "after")
    arg.set_any(
      [
        ::SOAP::SOAPElement.new("foo", "bar"),
        ::SOAP::SOAPElement.new("baz", "qux")
      ]
    )
    res = @client.echo(arg)
    assert_equal(arg.before, res.before)
    assert_equal("bar", res.foo)
    assert_equal("qux", res.baz)
    assert_equal(arg.after, res.after)
  end

  def test_naive
    @client = Echo_port_type.new
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = FooBar.new("before", "after")
    arg.set_any(
      [
        ::SOAP::SOAPElement.new("foo", "bar"),
        ::SOAP::SOAPElement.new("baz", "qux")
      ]
    )
    res = @client.echo(arg)
    assert_equal(arg.before, res.before)
    assert_equal("bar", res.foo)
    assert_equal("qux", res.baz)
    assert_equal(arg.after, res.after)
  end
end


end; end
