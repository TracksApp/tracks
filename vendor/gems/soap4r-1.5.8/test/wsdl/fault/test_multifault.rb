require 'test/unit'
require 'wsdl/soap/wsdl2ruby'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module Fault


class TestMultiFault < Test::Unit::TestCase
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
      File.unlink(pathname('Add.rb'))
      File.unlink(pathname('AddMappingRegistry.rb'))
      File.unlink(pathname('AddServant.rb'))
      File.unlink(pathname('AddService.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    AddPortType.class_eval do
      define_method(:add) do |request|
        @sum ||= 0
        if (request.value > 100)
          fault = AddFault.new("Value #{request.value} is too large", "Critical")
          raise fault
        end

        if (request.value < 0)
          fault = NegativeValueFault.new("Value #{request.value} is negative", "Fatal")
          raise fault
        end

        @sum += request.value
        return AddResponse.new(@sum)
      end
    end
    @server = AddPortTypeApp.new('app', nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("multifault.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['servant_skelton'] = nil
    gen.opt['standalone_server_stub'] = nil
    gen.opt['force'] = true
    TestUtil.silent do
      gen.run
    end
    TestUtil.require(DIR, 'Add.rb', 'AddMappingRegistry.rb', 'AddServant.rb', 'AddService.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_driver
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.mapping_registry = AddMappingRegistry::EncodedRegistry
    @client.literal_mapping_registry = AddMappingRegistry::LiteralRegistry
    @client.add_document_operation(
      "Add",
      "add",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://fault.test/Faulttest", "Add"]],
        ["out", "response", ["::SOAP::SOAPElement", "http://fault.test/Faulttest", "AddResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {"AddFault"=>{:namespace=>nil, :name=>"AddFault", :use=>"literal", :encodingstyle=>"document", :ns=>"http://fault.test/Faulttest"}} }
    )
    @client.wiredump_dev = STDOUT if $DEBUG
    do_test(@client)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'multifault.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.mapping_registry = AddMappingRegistry::EncodedRegistry
    @client.literal_mapping_registry = AddMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    do_test(@client)
  end

  def do_test(client)
    assert_equal(100, client.add(Add.new(100)).sum)
    assert_equal(100, client.add(Add.new(0)).sum)
    assert_equal(150, client.add(Add.new(50)).sum)
    begin
      client.add(Add.new(101))
      assert(false)
    rescue Exception => e
      assert_equal(::SOAP::FaultError, e.class)
      assert_equal("WSDL::Fault::AddFault", e.faultstring.data)
      assert_equal("Value 101 is too large", e.detail.addFault.reason)
      assert_equal("Critical", e.detail.addFault.severity)
    end
    begin
      client.add(Add.new(-50))
      assert(false)
    rescue Exception => e
      assert_equal(::SOAP::FaultError, e.class)
      assert_equal("WSDL::Fault::NegativeValueFault", e.faultstring.data)
      assert_equal("Value -50 is negative", e.detail.negativeValueFault.reason)
      assert_equal("Fatal", e.detail.negativeValueFault.severity)
    end
  end
end


end; end
