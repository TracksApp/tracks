require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module RPC


class TestRPC < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      add_rpc_method(self, 'echo', 'arg1', 'arg2')
      add_rpc_method(self, 'echo_basetype', 'arg1', 'arg2')
      add_rpc_method(self, 'echo_err', 'arg1', 'arg2')
      self.mapping_registry = Prefix::EchoMappingRegistry::EncodedRegistry
    end

    DummyPerson = Struct.new("family-name".intern, :Given_name)
    def echo(arg1, arg2)
      if arg1.given_name == 'typed'
        self.generate_explicit_type = true
      else
        self.generate_explicit_type = false
      end
      ret = nil
      case arg1.family_name
      when 'normal'
        arg1.family_name = arg2.family_name
        arg1.given_name = arg2.given_name
        arg1.age = arg2.age
        ret = arg1
      when 'dummy'
        ret = DummyPerson.new("family-name", "given_name")
      when 'nil'
        ret = Prefix::Person.new(nil, nil)
      else
        raise
      end
      ret
    end

    def echo_basetype(arg1, arg2)
      return nil if arg1.nil? and arg2.nil?
      raise unless arg1.is_a?(Date)
      arg1
    end

    ErrPerson = Struct.new(:Given_name, :no_such_element)
    def echo_err(arg1, arg2)
      self.generate_explicit_type = false
      ErrPerson.new(58, Time.now)
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
      File.unlink(pathname('echoMappingRegistry.rb'))
      File.unlink(pathname('echoDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:rpc", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    if ::Object.constants.include?("Echo")
      ::Object.instance_eval { remove_const("Echo") }
    end
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("rpc.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.opt['module_path'] = 'Prefix'
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

  def test_wsdl
    wsdl = File.join(DIR, 'rpc.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDERR if $DEBUG

    ret = @client.echo(Prefix::Person.new("normal", "typed", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_equal("Hi", ret.family_name)
    assert_equal("Na", ret.given_name)
    assert_equal(21, ret.age)

    ret = @client.echo(Prefix::Person.new("normal", "untyped", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_equal("Hi", ret.family_name)
    assert_equal("Na", ret.given_name)
    # XXX WSDLEncodedRegistry should decode untyped element using Schema
    assert_equal("21", ret.age)

    ret = @client.echo(Prefix::Person.new("dummy", "typed", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_equal("family-name", ret.family_name)
    assert_equal("given_name", ret.given_name)

    ret = @client.echo_err(Prefix::Person.new("Na", "Hi", nil, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", nil, Prefix::Gender::M))
    assert_equal("58", ret.given_name)
  end

  def test_stub
    @client = Prefix::Echo_port_type.new("http://localhost:#{Port}/")
    @client.mapping_registry = Prefix::EchoMappingRegistry::EncodedRegistry
    @client.wiredump_dev = STDERR if $DEBUG

    ret = @client.echo(Prefix::Person.new("normal", "typed", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_equal(Prefix::Person, ret.class)
    assert_equal("Hi", ret.family_name)
    assert_equal("Na", ret.given_name)
    assert_equal(21, ret.age)

    ret = @client.echo(Prefix::Person.new("normal", "untyped", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_equal(Prefix::Person, ret.class)
    assert_equal("Hi", ret.family_name)
    assert_equal("Na", ret.given_name)
    assert_equal(21, ret.age)
  end

  def test_stub_nil
    @client = Prefix::Echo_port_type.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG

    ret = @client.echo(Prefix::Person.new("nil", "", 12, Prefix::Gender::F), Prefix::Person.new("Hi", "Na", 21, Prefix::Gender::M))
    assert_nil(ret.family_name)
    assert_nil(ret.given_name)
    assert_nil(ret.age)
    #
    assert_nil(@client.echo_basetype(nil, nil))
  end

  def test_basetype_stub
    @client = Prefix::Echo_port_type.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG

    ret = @client.echo_basetype(Time.now, 12345)
    assert_equal(Date, ret.class)
  end
end


end; end
