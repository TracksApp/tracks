require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module ComplexContent


class TestEcho < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:complexContent'

    def on_init
      add_document_method(
        self,
        nil,
        'echo',
        XSD::QName.new(Namespace, 'echo'),
        XSD::QName.new(Namespace, 'echo')
      )
    end

    def echo(arg)
      arg
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
      File.unlink(pathname('complexContent.rb'))
      File.unlink(pathname('complexContentMappingRegistry.rb'))
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
    gen.location = pathname("complexContent.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'complexContentMappingRegistry.rb', 'complexContent.rb')
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
    wsdl = File.join(DIR, 'complexContent.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = ComplexContentMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    d = Derived.new
    d.name = "NaHi"
    assert_instance_of(Echo, @client.echo(Echo.new(d)))
  end
end


end; end
