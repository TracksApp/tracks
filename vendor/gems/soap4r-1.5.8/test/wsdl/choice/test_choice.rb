require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module Choice


class TestChoice < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:choice'

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(Namespace, 'echoele'),
        XSD::QName.new(Namespace, 'echo_response')
      )
      add_document_method(
        self,
        Namespace + ':echo_complex',
        'echo_complex',
        XSD::QName.new(Namespace, 'echoele_complex'),
        XSD::QName.new(Namespace, 'echo_complex_response')
      )
      add_document_method(
        self,
        Namespace + ':echo_complex_emptyArrayAtFirst',
        'echo_complex_emptyArrayAtFirst',
        XSD::QName.new(Namespace, 'echoele_complex_emptyArrayAtFirst'),
        XSD::QName.new(Namespace, 'echoele_complex_emptyArrayAtFirst')
      )
      @router.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry
    end

    def echo(arg)
      arg
    end

    def echo_complex(arg)
      Echo_complex_response.new(arg.data)
    end

    def echo_complex_emptyArrayAtFirst(arg)
      arg
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_classdef
    setup_server
    @client = nil
  end

  def teardown
    teardown_server if @server
    unless $DEBUG
      File.unlink(pathname('choice.rb'))
      File.unlink(pathname('choiceMappingRegistry.rb'))
      File.unlink(pathname('choiceDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("choice.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'choiceDriver.rb', 'choiceMappingRegistry.rb', 'choice.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'choice.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry

    ret = @client.echo(Echoele.new(TerminalID.new("imei", nil)))
    assert_equal("imei", ret.terminalID.imei)
    assert_nil(ret.terminalID.devId)
    ret = @client.echo(Echoele.new(TerminalID.new(nil, 'devId')))
    assert_equal("devId", ret.terminalID.devId)
    assert_nil(ret.terminalID.imei)
  end

  include ::SOAP
  def test_naive
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo', 'urn:choice:echo',
      XSD::QName.new('urn:choice', 'echoele'),
      XSD::QName.new('urn:choice', 'echo_response'))
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry

    echo = SOAPElement.new('echoele')
    echo.add(terminalID = SOAPElement.new('terminalID'))
    terminalID.add(SOAPElement.new('imei', 'imei'))
    ret = @client.echo(echo)
    assert_equal("imei", ret.terminalID.imei)
    assert_nil(ret.terminalID.devId)

    echo = SOAPElement.new('echoele')
    echo.add(terminalID = SOAPElement.new('terminalID'))
    terminalID.add(SOAPElement.new('devId', 'devId'))
    ret = @client.echo(echo)
    assert_equal("devId", ret.terminalID.devId)
    assert_nil(ret.terminalID.imei)
  end

  def test_wsdl_with_map_complex
    wsdl = File.join(DIR, 'choice.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    do_test_with_map_complex(@client)
  end

  def test_wsdl_with_stub_complex
    wsdl = File.join(DIR, 'choice.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry
    do_test_with_stub_complex(@client)
  end

  def test_naive_with_map_complex
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo_complex', 'urn:choice:echo_complex',
      XSD::QName.new('urn:choice', 'echoele_complex'),
      XSD::QName.new('urn:choice', 'echo_complex_response'))
    @client.wiredump_dev = STDOUT if $DEBUG
    do_test_with_map_complex(@client)
  end

  def test_naive_with_stub_complex
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo_complex', 'urn:choice:echo_complex',
      XSD::QName.new('urn:choice', 'echoele_complex'),
      XSD::QName.new('urn:choice', 'echo_complex_response'))
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry
    do_test_with_stub_complex(@client)
  end

  def do_test_with_map_complex(client)
    req = {
      :data => {
        :A => "A",
        :B1 => "B1",
        :C1 => "C1",
        :C2 => "C2"
      }
    }
    ret = client.echo_complex(req)
    assert_equal("A", ret.data["A"])
    assert_equal("B1", ret.data["B1"])
    assert_equal(nil, ret.data["B2a"])
    assert_equal(nil, ret.data["B2b"])
    assert_equal(nil, ret.data["B3a"])
    assert_equal(nil, ret.data["B3b"])
    assert_equal("C1", ret.data["C1"])
    assert_equal("C2", ret.data["C2"])
    #
    req = {
      :data => {
        :A => "A",
        :B2a => "B2a",
        :B2b => "B2b",
        :C1 => "C1",
        :C2 => "C2"
      }
    }
    ret = client.echo_complex(req)
    assert_equal("A", ret.data["A"])
    assert_equal(nil, ret.data["B1"])
    assert_equal("B2a", ret.data["B2a"])
    assert_equal("B2b", ret.data["B2b"])
    assert_equal(nil, ret.data["B3a"])
    assert_equal(nil, ret.data["B3b"])
    assert_equal("C1", ret.data["C1"])
    assert_equal("C2", ret.data["C2"])
    #
    req = {
      :data => {
        :A => "A",
        :B3a => "B3a",
        :C1 => "C1",
        :C2 => "C2"
      }
    }
    ret = client.echo_complex(req)
    assert_equal("A", ret.data["A"])
    assert_equal(nil, ret.data["B1"])
    assert_equal(nil, ret.data["B2a"])
    assert_equal(nil, ret.data["B2b"])
    assert_equal("B3a", ret.data["B3a"])
    assert_equal(nil, ret.data["B3b"])
    assert_equal("C1", ret.data["C1"])
    assert_equal("C2", ret.data["C2"])
    #
    req = {
      :data => {
        :A => "A",
        :B3b => "B3b",
        :C1 => "C1",
        :C2 => "C2"
      }
    }
    ret = client.echo_complex(req)
    assert_equal("A", ret.data["A"])
    assert_equal(nil, ret.data["B1"])
    assert_equal(nil, ret.data["B2a"])
    assert_equal(nil, ret.data["B2b"])
    assert_equal(nil, ret.data["B3a"])
    assert_equal("B3b", ret.data["B3b"])
    assert_equal("C1", ret.data["C1"])
    assert_equal("C2", ret.data["C2"])
  end

  def do_test_with_stub_complex(client)
    ret = client.echo_complex(Echoele_complex.new(Andor.new("A", "B1", nil, nil, nil, nil, "C1", "C2")))
    assert_equal("A", ret.data.a)
    assert_equal("B1", ret.data.b1)
    assert_equal(nil, ret.data.b2a)
    assert_equal(nil, ret.data.b2b)
    assert_equal(nil, ret.data.b3a)
    assert_equal(nil, ret.data.b3b)
    assert_equal("C1", ret.data.c1)
    assert_equal("C2", ret.data.c2)
    #
    ret = client.echo_complex(Echoele_complex.new(Andor.new("A", nil, "B2a", "B2b", nil, nil, "C1", "C2")))
    assert_equal("A", ret.data.a)
    assert_equal(nil, ret.data.b1)
    assert_equal("B2a", ret.data.b2a)
    assert_equal("B2b", ret.data.b2b)
    assert_equal(nil, ret.data.b3a)
    assert_equal(nil, ret.data.b3b)
    assert_equal("C1", ret.data.c1)
    assert_equal("C2", ret.data.c2)
    #
    ret = client.echo_complex(Echoele_complex.new(Andor.new("A", nil, nil, nil, "B3a", nil, "C1", "C2")))
    assert_equal("A", ret.data.a)
    assert_equal(nil, ret.data.b1)
    assert_equal(nil, ret.data.b2a)
    assert_equal(nil, ret.data.b2b)
    assert_equal("B3a", ret.data.b3a)
    assert_equal(nil, ret.data.b3b)
    assert_equal("C1", ret.data.c1)
    assert_equal("C2", ret.data.c2)
    #
    ret = client.echo_complex(Echoele_complex.new(Andor.new("A", nil, nil, nil, nil, "B3b", "C1", "C2")))
    assert_equal("A", ret.data.a)
    assert_equal(nil, ret.data.b1)
    assert_equal(nil, ret.data.b2a)
    assert_equal(nil, ret.data.b2b)
    assert_equal(nil, ret.data.b3a)
    assert_equal("B3b", ret.data.b3b)
    assert_equal("C1", ret.data.c1)
    assert_equal("C2", ret.data.c2)
  end

  def test_stub_emptyArrayAtFirst
    @client = Choice_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    #
    arg = EmptyArrayAtFirst.new
    arg.b1 = "b1"
    ret = @client.echo_complex_emptyArrayAtFirst(Echoele_complex_emptyArrayAtFirst.new(arg))
    assert_nil(ret.data.a)
    assert_equal("b1", ret.data.b1)
    assert_nil(ret.data.b2)
  end
end


end; end
