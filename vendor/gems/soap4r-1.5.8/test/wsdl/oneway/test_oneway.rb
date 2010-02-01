require 'test/unit'
require 'soap/rpc/standaloneServer'
require 'wsdl/soap/wsdl2ruby'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL
module Oneway


class TestOneway < Test::Unit::TestCase
  NS = 'http://www.example.com/oneway'
  class Server < ::SOAP::RPC::StandaloneServer
    Methods = [
      [ "initiate",
        "initiate",
        [ ["in", "payload", ["::SOAP::SOAPElement", "http://www.example.com/oneway", "onewayProcessRequest"]] ],
        { :request_style =>  :document, :request_use =>  :literal,
          :response_style => :document, :response_use => nil,
          :faults => {} }
      ]
    ]

    def on_init
      Methods.each do |definition|
        add_document_operation(self, *definition)
      end
      self.mapping_registry = OnewayMappingRegistry::EncodedRegistry
      self.literal_mapping_registry = OnewayMappingRegistry::LiteralRegistry
    end

    def initiate(payload)
      raise unless payload.msg
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
      File.unlink(pathname('oneway.rb'))
      File.unlink(pathname('onewayMappingRegistry.rb'))
      File.unlink(pathname('onewayDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "http://www.example.com/oneway", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("oneway.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.opt['module_path'] = 'WSDL::Oneway'
    gen.run
    TestUtil.require(DIR, 'oneway.rb', 'onewayDriver.rb', 'onewayMappingRegistry.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_stub
    @client = OnewayPort.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG
    # not raised
    @client.initiate(OnewayProcessRequest.new("msg"))
    @client.initiate(OnewayProcessRequest.new(nil))
  end

  def test_wsdl
    @client = ::SOAP::WSDLDriverFactory.new(pathname('oneway.wsdl')).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDERR if $DEBUG
    # not raised
    @client.initiate(OnewayProcessRequest.new("msg"))
    @client.initiate(OnewayProcessRequest.new(nil))
  end
end


end
end
