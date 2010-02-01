require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module List


class TestList < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:list'

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(Namespace, 'echoele'),
        XSD::QName.new(Namespace, 'echo_response')
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
    File.unlink(pathname('list.rb')) unless $DEBUG
    File.unlink(pathname('listMappingRegistry.rb')) unless $DEBUG
    File.unlink(pathname('listDriver.rb')) unless $DEBUG
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("list.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'listDriver.rb', 'listMappingRegistry.rb', 'list.rb')
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
    wsdl = File.join(DIR, 'list.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    e1 = Langlistinline.new([Langlistinline::Inlineruby,
      Langlistinline::Inlineperl])
    e2 = Langlist.new([Language::Python, Language::Smalltalk])
    ret = @client.echo(Echoele.new(e1, e2))
    # in the future...
    #   assert_equal(e1, ret.e1)
    #   assert_equal(e2, ret.e2)
    assert_equal(e1.join(" "), ret.e1)
    assert_equal(e2.join(" "), ret.e2)
  end

  def test_naive
    @client = List_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    e1 = Langlistinline.new([Langlistinline::Inlineruby,
      Langlistinline::Inlineperl])
    e2 = Langlist.new([Language::Python, Language::Smalltalk])
    ret = @client.echo(Echoele.new(e1, e2))
    # in the future...
    #   assert_equal(e1, ret.e1)
    #   assert_equal(e2, ret.e2)
    assert_equal(e1.join(" "), ret.e1)
    assert_equal(e2.join(" "), ret.e2)
  end

  def test_string_as_a_value
    @client = List_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    e1 = ['inlineruby', 'inlineperl']
    e2 = 'python smalltalk'
    ret = @client.echo(Echoele.new(e1, e2))
    # in the future...
    #   assert_equal(e1, ret.e1)
    #   assert_equal(e2, ret.e2)
    assert_equal(e1.join(" "), ret.e1)
    assert_equal(e2, ret.e2)
  end
end


end; end
