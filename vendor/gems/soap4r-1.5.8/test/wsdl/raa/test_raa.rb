require 'test/unit'
require 'soap/wsdlDriver'
require 'wsdl/soap/wsdl2ruby'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL
module RAA


class TestRAA < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_stub
    setup_server
    setup_client
  end

  def setup_stub
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("raa.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'RAADriver.rb', 'RAAMappingRegistry.rb', 'RAA.rb')
  end

  def setup_server
    require pathname('RAAService.rb')
    @server = RAABaseServicePortTypeApp.new('RAA server', nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      Thread.current.abort_on_exception = true
      @server.start
    }
  end

  def setup_client
    wsdl = File.join(DIR, 'raa.wsdl')
    @raa = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @raa.endpoint_url = "http://localhost:#{Port}/"
    @raa.wiredump_dev = STDOUT if $DEBUG
    @raa.mapping_registry = RAAMappingRegistry::EncodedRegistry
    @raa.literal_mapping_registry = RAAMappingRegistry::LiteralRegistry
  end

  def teardown
    teardown_server if @server
    teardown_client if @client
    unless $DEBUG
      File.unlink(pathname('RAA.rb'))
      File.unlink(pathname('RAAMappingRegistry.rb'))
      File.unlink(pathname('RAADriver.rb'))
    end
  end

  def teardown_server
    @server.shutdown
    @t.kill
    @t.join
  end

  def teardown_client
    @raa.reset_stream
  end

  def test_stubgeneration
    compare("expectedClassDef.rb", "RAA.rb")
    compare("expectedMappingRegistry.rb", "RAAMappingRegistry.rb")
    compare("expectedDriver.rb", "RAADriver.rb")
  end

  def test_raa
    do_test_raa(@raa)
  end

  def test_stub
    client = RAABaseServicePortType.new("http://localhost:#{Port}/")
    do_test_raa(client)
  end

  def do_test_raa(client)
    assert_equal(["ruby", "soap4r"], client.getAllListings)
    info = client.getInfoFromName("SOAP4R")
    assert_equal(Info, info.class)
    assert_equal(Category, info.category.class)
    assert_equal(Product, info.product.class)
    assert_equal(Owner, info.owner.class)
    assert_equal("major", info.category.major)
    assert_equal("minor", info.category.minor)
    assert_equal(123, info.product.id)
    assert_equal("SOAP4R", info.product.name)
    assert_equal("short description", info.product.short_description)
    assert_equal("version", info.product.version)
    assert_equal("status", info.product.status)
    assert_equal("http://example.com/homepage", info.product.homepage.to_s)
    assert_equal("http://example.com/download", info.product.download.to_s)
    assert_equal("license", info.product.license)
    assert_equal("description", info.product.description)
    assert_equal(456, info.owner.id)
    assert_equal("mailto:email@example.com", info.owner.email.to_s)
    assert_equal("name", info.owner.name)
    assert(!info.created.nil?)
    assert(!info.updated.nil?)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def pathname(filename)
    File.join(DIR, filename)
  end
end


end
end
