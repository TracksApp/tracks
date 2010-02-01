require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module Document


class TestRPC < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:docrpc'

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(Namespace, 'echo'),
        XSD::QName.new(Namespace, 'echo_response')
      )
      add_document_method(
        self,
        Namespace + ':return_nil',
        'return_nil',
        nil,
        XSD::QName.new(Namespace, 'echo_response')
      )
      add_document_method(
        self,
        Namespace + ':return_empty',
        'return_empty',
        nil,
        XSD::QName.new(Namespace, 'echo_response')
      )
      self.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    end

    def echo(arg)
      if arg.is_a?(Echoele)
        # swap args
        tmp = arg.struct1
        arg.struct1 = arg.struct_2
        arg.struct_2 = tmp
        arg
      else
        # swap args
        tmp = arg["struct1"]
        arg["struct1"] = arg["struct-2"]
        arg["struct-2"] = tmp
        arg
      end
    end

    def return_nil
      e = Echoele.new
      e.struct1 = Echo_struct.new(nil, nil)
      e.struct_2 = Echo_struct.new(nil, nil)
      e.long = nil
      e
    end

    def return_empty
      e = Echoele.new
      e.struct1 = Echo_struct.new("", nil)
      e.struct_2 = Echo_struct.new("", nil)
      e.long = 0
      e
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
    File.unlink(pathname('echo.rb')) unless $DEBUG
    File.unlink(pathname('echoMappingRegistry.rb')) unless $DEBUG
    File.unlink(pathname('echoDriver.rb')) unless $DEBUG
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:rpc", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("document.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
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

  def test_wsdl
    wsdl = File.join(DIR, 'document.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    do_test_with_stub(@client)
  end

  def test_driver_stub
    @client = ::WSDL::Document::Docrpc_porttype.new
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    do_test_with_stub(@client)
  end

  def test_nil_attribute
    @client = ::WSDL::Document::Docrpc_porttype.new
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    struct1 = Echo_struct.new("mystring1", now1 = Time.now)
    struct1.xmlattr_m_attr = nil
    struct2 = Echo_struct.new("mystr<>ing2", now2 = Time.now)
    struct2.xmlattr_m_attr = ''
    echo = Echoele.new(struct1, struct2, 105759347)
    echo.xmlattr_attr_string = ''
    echo.xmlattr_attr_int = nil
    ret = @client.echo(echo)
    # struct1 and struct2 are swapped
    assert_equal('', ret.struct1.xmlattr_m_attr)
    assert_equal(nil, ret.struct_2.xmlattr_m_attr)
    assert_equal('', ret.xmlattr_attr_string)
    assert_equal(nil, ret.xmlattr_attr_int)
    assert_equal(105759347, ret.long)
  end

  def do_test_with_stub(client)
    struct1 = Echo_struct.new("mystring1", now1 = Time.now)
    struct1.xmlattr_m_attr = 'myattr1'
    struct2 = Echo_struct.new("mystr<>ing2", now2 = Time.now)
    struct2.xmlattr_m_attr = 'myattr2'
    echo = Echoele.new(struct1, struct2, 105759347)
    echo.xmlattr_attr_string = 'attr_str<>ing'
    echo.xmlattr_attr_int = 5
    ret = client.echo(echo)

    # struct#m_datetime in a response is a DateTime even though
    # struct#m_datetime in a request is a Time.
    timeformat = "%Y-%m-%dT%H:%M:%S"
    assert_equal("mystr<>ing2", ret.struct1.m_string)
    assert_equal(now2.strftime(timeformat),
      date2time(ret.struct1.m_datetime).strftime(timeformat))
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal(now1.strftime(timeformat),
      date2time(ret.struct_2.m_datetime).strftime(timeformat))
    assert_equal("attr_str<>ing", ret.xmlattr_attr_string)
    assert_equal(5, ret.xmlattr_attr_int)
    assert_equal(105759347, ret.long)
  end

  def test_wsdl_with_map
    wsdl = File.join(DIR, 'document.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG

    struct1 = {
      :m_string => "mystring1",
      :m_datetime => (now1 = Time.now),
      :xmlattr_m_attr => "myattr1"
    }
    struct2 = {
      "m_string" => "mystr<>ing2",
      "m_datetime" => now2 = (Time.now),
      "xmlattr_m_attr" => "myattr2"
    }
    echo = {
      :struct1 => struct1,
      "struct-2" => struct2,
      :xmlattr_attr_string => 'attr_str<>ing',
      "xmlattr_attr-int" => 5
    }
    ret = @client.echo(echo)
    #
    now1str = XSD::XSDDateTime.new(now1).to_s
    now2str = XSD::XSDDateTime.new(now2).to_s
    assert_equal("mystr<>ing2", ret.struct1.m_string)
    assert_equal(now2str, ret.struct1.m_datetime)
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal(now1str, ret.struct_2.m_datetime)
    assert_equal("attr_str<>ing", ret.xmlattr_attr_string)
    assert_equal("5", ret.xmlattr_attr_int)
  end

  def date2time(date)
    if date.respond_to?(:to_time)
      date.to_time
    else
      d = date.new_offset(0)
      d.instance_eval {
        Time.utc(year, mon, mday, hour, min, sec,
          (sec_fraction * 86400000000).to_i)
      }.getlocal
    end
  end

  include ::SOAP
  def test_naive
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo', 'urn:docrpc:echo',
      XSD::QName.new('urn:docrpc', 'echoele'),
      XSD::QName.new('urn:docrpc', 'echo_response'))
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG

    echo = SOAPElement.new('foo')
    echo.extraattr['attr_string'] = 'attr_str<>ing'
    echo.extraattr['attr-int'] = 5
    echo.add(struct1 = SOAPElement.new('struct1'))
    struct1.add(SOAPElement.new('m_string', 'mystring1'))
    struct1.add(SOAPElement.new('m_datetime', '2005-03-17T19:47:31+01:00'))
    struct1.extraattr['m_attr'] = 'myattr1'
    echo.add(struct2 = SOAPElement.new('struct-2'))
    struct2.add(SOAPElement.new('m_string', 'mystring2'))
    struct2.add(SOAPElement.new('m_datetime', '2005-03-17T19:47:32+02:00'))
    struct2.extraattr['m_attr'] = 'myattr2'
    ret = @client.echo(echo)
    timeformat = "%Y-%m-%dT%H:%M:%S"
    assert_equal('mystring2', ret.struct1.m_string)
    assert_equal('2005-03-17T19:47:32',
      ret.struct1.m_datetime.strftime(timeformat))
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal('2005-03-17T19:47:31',
      ret.struct_2.m_datetime.strftime(timeformat))
    assert_equal('attr_str<>ing', ret.xmlattr_attr_string)
    assert_equal(5, ret.xmlattr_attr_int)

    echo = {'struct1' => {'m_string' => 'mystring1', 'm_datetime' => '2005-03-17T19:47:31+01:00'},
          'struct_2' => {'m_string' => 'mystring2', 'm_datetime' => '2005-03-17T19:47:32+02:00'}}
    ret = @client.echo(echo)
    timeformat = "%Y-%m-%dT%H:%M:%S"
    assert_equal('mystring2', ret.struct1.m_string)
    assert_equal('2005-03-17T19:47:32',
      ret.struct1.m_datetime.strftime(timeformat))
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal('2005-03-17T19:47:31',
      ret.struct_2.m_datetime.strftime(timeformat))
  end

  def test_to_xml
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo', 'urn:docrpc:echo',
      XSD::QName.new('urn:docrpc', 'echoele'),
      XSD::QName.new('urn:docrpc', 'echo_response'))
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG

    require 'rexml/document'
    echo = REXML::Document.new(<<__XML__.chomp)
<foo attr-int="5" attr_string="attr_string">
  <struct1 m_attr="myattr1">
    <m_string>mystring1</m_string>
    <m_datetime>2005-03-17T19:47:31+01:00</m_datetime>
  </struct1>
  <struct-2 m_attr="myattr2">
    <m_string>mystring2</m_string>
    <m_datetime>2005-03-17T19:47:32+02:00</m_datetime>
  </struct-2>
</foo>
__XML__
    ret = @client.echo(echo)
    timeformat = "%Y-%m-%dT%H:%M:%S"
    assert_equal('mystring2', ret.struct1.m_string)
    assert_equal('2005-03-17T19:47:32',
      ret.struct1.m_datetime.strftime(timeformat))
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal('2005-03-17T19:47:31',
      ret.struct_2.m_datetime.strftime(timeformat))
    assert_equal('attr_string', ret.xmlattr_attr_string)
    assert_equal(5, ret.xmlattr_attr_int)
    #
    echoele = REXML::Document.new(<<__XML__.chomp)
<n1:echoele xmlns:n1="urn:docrpc">
  <struct-2>
    <m_datetime>2005-03-17T19:47:32+02:00</m_datetime>
    <m_string>mystring2</m_string>
  </struct-2>
  <struct1>
    <m_datetime>2005-03-17T19:47:31+01:00</m_datetime>
    <m_string>mystring1</m_string>
  </struct1>
</n1:echoele>
__XML__
    ret = @client.echo(echoele)
    timeformat = "%Y-%m-%dT%H:%M:%S"
    assert_equal('mystring2', ret.struct1.m_string)
    assert_equal('2005-03-17T19:47:32',
      ret.struct1.m_datetime.strftime(timeformat))
    assert_equal("mystring1", ret.struct_2.m_string)
    assert_equal('2005-03-17T19:47:31',
      ret.struct_2.m_datetime.strftime(timeformat))
  end

  def test_nil
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('return_nil', 'urn:docrpc:return_nil',
      nil,
      XSD::QName.new('urn:docrpc', 'return_nil'))
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG

    ret = @client.return_nil
    assert_nil(ret.struct1.m_string)
    assert_nil(ret.struct_2.m_string)
    assert_nil(ret.long)
  end

  def test_empty
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('return_empty', 'urn:docrpc:return_empty',
      nil,
      XSD::QName.new('urn:docrpc', 'return_empty'))
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG

    ret = @client.return_empty
    assert_equal("", ret.struct1.m_string)
    assert_equal("", ret.struct_2.m_string)
    assert_equal(0, ret.long)
  end
end


end; end
