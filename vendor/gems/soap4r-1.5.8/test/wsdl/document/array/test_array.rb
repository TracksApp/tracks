require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', 'testutil.rb')


module WSDL; module Document


class TestArray < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'http://tempuri.org/'

    def on_init
      add_document_method(
        self,
        Namespace + 'echo',
        'echo',
        XSD::QName.new(Namespace, 'echo'),
        XSD::QName.new(Namespace, 'echoResponse')
      )
      add_document_method(
        self,
        Namespace + 'echo2',
        'echo2',
        XSD::QName.new(Namespace, 'echo2'),
        XSD::QName.new(Namespace, 'echo2Response')
      )
      add_document_method(
        self,
        Namespace + 'echo3',
        'echo3',
        XSD::QName.new(Namespace, 'ArrayOfRecord'),
        XSD::QName.new(Namespace, 'ArrayOfRecord')
      )
      self.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    end

    def echo(arg)
      arg
    end

    def echo2(arg)
      arg
    end

    def echo3(arg)
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
      File.unlink(pathname('double.rb'))
      File.unlink(pathname('doubleMappingRegistry.rb'))
      File.unlink(pathname('doubleDriver.rb'))
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
    gen.location = pathname("double.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'doubleDriver.rb', 'doubleMappingRegistry.rb', 'double.rb')
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
    @client = PricerSoap.new
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = ArrayOfComplex[c1 = Complex.new, c2 = Complex.new, c3 = Complex.new]
    c1.string = "str_c1"
    c1.double = 1.1
    c2.string = "str_c2"
    c2.double = 2.2
    c3.string = "str_c3"
    c3.double = 3.3
    ret = @client.echo2(Echo2.new(arg))
    assert_equal(ArrayOfComplex, ret.arg.class)
    assert_equal(Complex, ret.arg[0].class)
    assert_equal(arg[0].string, ret.arg[0].string)
    assert_equal(arg[1].string, ret.arg[1].string)
    assert_equal(arg[2].string, ret.arg[2].string)
  end

  def test_wsdl_stubclassdef
    wsdl = File.join(DIR, 'double.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = ArrayOfDouble[0.1, 0.2, 0.3]
    assert_equal(arg, @client.echo(Echo.new(arg)).ary)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'double.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    double = [0.1, 0.2, 0.3]
    assert_equal(double, @client.echo(:ary => double).ary)
  end

  def test_stub
    @client = ::WSDL::Document::PricerSoap.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    double = [0.1, 0.2, 0.3]
    assert_equal(double, @client.echo(:ary => double).ary)
  end

  def test_stub_nil
    @client = ::WSDL::Document::PricerSoap.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    assert_equal(nil, @client.echo(Echo.new).ary)
  end

  def test_attribute_array
    @client = ::WSDL::Document::PricerSoap.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    #
    r1 = ReportRecord.new
    r1.xmlattr_a = "r1_xmlattr_a"
    r1.xmlattr_b = "r1_xmlattr_b"
    r1.xmlattr_c = "r1_xmlattr_c"
    r2 = ReportRecord.new
    r2.xmlattr_a = "r2_xmlattr_a"
    r2.xmlattr_b = "r2_xmlattr_b"
    r2.xmlattr_c = "r2_xmlattr_c"
    arg = ArrayOfRecord[r1, r2]
    ret = @client.echo3(arg)
    assert_equal(arg.class , ret.class)
    assert_equal(arg.size , ret.size)
    assert_equal(2, ret.size)
    assert_equal(arg[0].class, ret[0].class)
    assert_equal(arg[0].xmlattr_a, ret[0].xmlattr_a)
    assert_equal(arg[0].xmlattr_b, ret[0].xmlattr_b)
    assert_equal(arg[0].xmlattr_c, ret[0].xmlattr_c)
    assert_equal(arg[1].class, ret[1].class)
    assert_equal(arg[1].xmlattr_a, ret[1].xmlattr_a)
    assert_equal(arg[1].xmlattr_b, ret[1].xmlattr_b)
    assert_equal(arg[1].xmlattr_c, ret[1].xmlattr_c)
    #
    arg = ArrayOfRecord[r1]
    ret = @client.echo3(arg)
    assert_equal(arg.class , ret.class)
    assert_equal(arg.size , ret.size)
    assert_equal(1, ret.size)
    assert_equal(arg[0].class, ret[0].class)
    assert_equal(arg[0].xmlattr_a, ret[0].xmlattr_a)
    assert_equal(arg[0].xmlattr_b, ret[0].xmlattr_b)
    assert_equal(arg[0].xmlattr_c, ret[0].xmlattr_c)
    #
    arg = ArrayOfRecord[]
    ret = @client.echo3(arg)
    assert_equal(arg.class , ret.class)
    assert_equal(arg.size , ret.size)
    assert_equal(0, ret.size)
  end
end


end; end
