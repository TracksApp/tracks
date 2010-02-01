require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', '..', 'testutil.rb')


module WSDL; module SOAP; module T_WSDL2Ruby


class TestSOAPENC < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      add_rpc_method(self, 'echo_version', 'version')
    end

    def echo_version(version)
      Version_struct.new(version, "hello")
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
      File.unlink(pathname('echo.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:example.com:soapenc", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    if ::Object.constants.include?("Version_struct")
      ::Object.instance_eval { remove_const("Version_struct") }
    end
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("soapenc.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'echo.rb')
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
    wsdl = File.join(DIR, 'soapenc.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    ret = @client.echo_version(T_version::C_19)
    assert_equal(T_version::C_19, ret.version)
    assert_equal("hello", ret.msg)
  end
end


end; end; end
