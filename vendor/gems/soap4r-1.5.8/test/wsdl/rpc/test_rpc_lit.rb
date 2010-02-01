require 'test/unit'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


if defined?(HTTPClient) and defined?(OpenSSL)

module WSDL; module RPC


class TestRPCLIT < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = "http://soapbuilders.org/rpc-lit-test"

    def on_init
      self.generate_explicit_type = false
      self.literal_mapping_registry = RPCLiteralTestDefinitionsMappingRegistry::LiteralRegistry
      add_rpc_operation(self,
        XSD::QName.new(Namespace, 'echoStringArray'),
        nil,
        'echoStringArray', [
          ['in', 'inputStringArray', nil],
          ['retval', 'return', nil]
        ],
        {
          :request_style => :rpc,
          :request_use => :literal,
          :response_style => :rpc,
          :response_use => :literal
        }
      )
      add_rpc_operation(self,
        XSD::QName.new(Namespace, 'echoStringArrayInline'),
        nil,
        'echoStringArrayInline', [
          ['in', 'inputStringArray', nil],
          ['retval', 'return', nil]
        ],
        {
          :request_style => :rpc,
          :request_use => :literal,
          :response_style => :rpc,
          :response_use => :literal
        }
      )
      add_rpc_operation(self,
        XSD::QName.new(Namespace, 'echoNestedStruct'),
        nil,
        'echoNestedStruct', [
          ['in', 'inputNestedStruct', nil],
          ['retval', 'return', nil]
        ],
        {
          :request_style => :rpc,
          :request_use => :literal,
          :response_style => :rpc,
          :response_use => :literal
        }
      )
      add_rpc_operation(self,
        XSD::QName.new(Namespace, 'echoStructArray'),
        nil,
        'echoStructArray', [
          ['in', 'inputStructArray', nil],
          ['retval', 'return', nil]
        ],
        {
          :request_style => :rpc,
          :request_use => :literal,
          :response_style => :rpc,
          :response_use => :literal
        }
      )
    end

    def echoStringArray(strings)
      # strings.stringItem => Array
      ArrayOfstring[*strings.stringItem]
    end

    def echoStringArrayInline(strings)
      ArrayOfstringInline[*strings.stringItem]
    end

    def echoNestedStruct(struct)
      struct
    end

    def echoStructArray(ary)
      ary
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
      File.unlink(pathname('RPC-Literal-TestDefinitions.rb'))
      File.unlink(pathname('RPC-Literal-TestDefinitionsMappingRegistry.rb'))
      File.unlink(pathname('RPC-Literal-TestDefinitionsDriver.rb'))
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
    gen.location = pathname("test-rpc-lit.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'RPC-Literal-TestDefinitions.rb', 'RPC-Literal-TestDefinitionsMappingRegistry.rb', 'RPC-Literal-TestDefinitionsDriver.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_wsdl_echoStringArray
    wsdl = pathname('test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    # response contains only 1 part.
    result = @client.echoStringArray(ArrayOfstring["a", "b", "c"])[0]
    assert_equal(["a", "b", "c"], result.stringItem)
  end

  ECHO_STRING_ARRAY_REQUEST =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStringArray xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <inputStringArray xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <n2:stringItem>a</n2:stringItem>
        <n2:stringItem>b</n2:stringItem>
        <n2:stringItem>c</n2:stringItem>
      </inputStringArray>
    </n1:echoStringArray>
  </env:Body>
</env:Envelope>]

  ECHO_STRING_ARRAY_RESPONSE =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStringArrayResponse xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <n1:return xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <n2:stringItem>a</n2:stringItem>
        <n2:stringItem>b</n2:stringItem>
        <n2:stringItem>c</n2:stringItem>
      </n1:return>
    </n1:echoStringArrayResponse>
  </env:Body>
</env:Envelope>]

  def test_stub_echoStringArray
    drv = SoapTestPortTypeRpcLit.new("http://localhost:#{Port}/")
    drv.wiredump_dev = str = ''
    drv.generate_explicit_type = false
    # response contains only 1 part.
    result = drv.echoStringArray(ArrayOfstring["a", "b", "c"])[0]
    assert_equal(ECHO_STRING_ARRAY_REQUEST, parse_requestxml(str),
      [ECHO_STRING_ARRAY_REQUEST, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_STRING_ARRAY_RESPONSE, parse_responsexml(str),
      [ECHO_STRING_ARRAY_RESPONSE, parse_responsexml(str)].join("\n\n"))
    assert_equal(ArrayOfstring["a", "b", "c"], result)
  end

  ECHO_STRING_ARRAY_INLINE_REQUEST =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStringArrayInline xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <inputStringArray>
        <stringItem>a</stringItem>
        <stringItem>b</stringItem>
        <stringItem>c</stringItem>
      </inputStringArray>
    </n1:echoStringArrayInline>
  </env:Body>
</env:Envelope>]

  ECHO_STRING_ARRAY_INLINE_RESPONSE =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStringArrayInlineResponse xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <n1:return>
        <stringItem>a</stringItem>
        <stringItem>b</stringItem>
        <stringItem>c</stringItem>
      </n1:return>
    </n1:echoStringArrayInlineResponse>
  </env:Body>
</env:Envelope>]

  def test_stub_echoStringArrayInline
    drv = SoapTestPortTypeRpcLit.new("http://localhost:#{Port}/")
    drv.wiredump_dev = str = ''
    drv.generate_explicit_type = false
    # response contains only 1 part.
    result = drv.echoStringArrayInline(ArrayOfstringInline["a", "b", "c"])[0]
    assert_equal(ArrayOfstring["a", "b", "c"], result)
    assert_equal(ECHO_STRING_ARRAY_INLINE_REQUEST, parse_requestxml(str),
      [ECHO_STRING_ARRAY_INLINE_REQUEST, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_STRING_ARRAY_INLINE_RESPONSE, parse_responsexml(str))
  end

  ECHO_NESTED_STRUCT_REQUEST =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoNestedStruct xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <inputStruct xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <varString>str</varString>
        <varInt>1</varInt>
        <varFloat>+1</varFloat>
        <n2:structItem>
          <varString>str</varString>
          <varInt>1</varInt>
          <varFloat>+1</varFloat>
        </n2:structItem>
      </inputStruct>
    </n1:echoNestedStruct>
  </env:Body>
</env:Envelope>]

  ECHO_NESTED_STRUCT_RESPONSE =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoNestedStructResponse xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <n1:return xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <varString>str</varString>
        <varInt>1</varInt>
        <varFloat>+1</varFloat>
        <n2:structItem>
          <varString>str</varString>
          <varInt>1</varInt>
          <varFloat>+1</varFloat>
        </n2:structItem>
      </n1:return>
    </n1:echoNestedStructResponse>
  </env:Body>
</env:Envelope>]

  def test_wsdl_echoNestedStruct
    wsdl = pathname('test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = str = ''
    @client.generate_explicit_type = false
    # response contains only 1 part.
    result = @client.echoNestedStruct(SOAPStructStruct.new("str", 1, 1.0, SOAPStruct.new("str", 1, 1.0)))[0]
    assert_equal('str', result.varString)
    assert_equal('1', result.varInt)
    assert_equal('+1', result.varFloat)
    assert_equal('str', result.structItem.varString)
    assert_equal('1', result.structItem.varInt)
    assert_equal('+1', result.structItem.varFloat)
    assert_equal(ECHO_NESTED_STRUCT_REQUEST, parse_requestxml(str),
      [ECHO_NESTED_STRUCT_REQUEST, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_NESTED_STRUCT_RESPONSE, parse_responsexml(str))
  end

  ECHO_NESTED_STRUCT_REQUEST_NIL =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoNestedStruct xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <inputStruct xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <varString>str</varString>
        <varFloat>+1</varFloat>
        <n2:structItem>
          <varString>str</varString>
          <varInt xsi:nil="true"></varInt>
          <varFloat>+1</varFloat>
        </n2:structItem>
      </inputStruct>
    </n1:echoNestedStruct>
  </env:Body>
</env:Envelope>]

  ECHO_NESTED_STRUCT_RESPONSE_NIL =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoNestedStructResponse xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <n1:return xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <varString>str</varString>
        <varFloat>+1</varFloat>
        <n2:structItem>
          <varString>str</varString>
          <varFloat>+1</varFloat>
        </n2:structItem>
      </n1:return>
    </n1:echoNestedStructResponse>
  </env:Body>
</env:Envelope>]
  def test_wsdl_echoNestedStruct_nil
    wsdl = pathname('test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = str = ''
    @client.generate_explicit_type = false
    result = @client.echoNestedStruct(SOAPStructStruct.new("str", nil, 1.0, SOAPStruct.new("str", ::SOAP::SOAPNil.new, 1.0)))[0]
    assert(!result.respond_to?(:varInt))
    assert(result.respond_to?(:varString))
    assert_equal(ECHO_NESTED_STRUCT_REQUEST_NIL, parse_requestxml(str),
      [ECHO_NESTED_STRUCT_REQUEST_NIL, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_NESTED_STRUCT_RESPONSE_NIL, parse_responsexml(str))
  end

  def test_stub_echoNestedStruct
    drv = SoapTestPortTypeRpcLit.new("http://localhost:#{Port}/")
    drv.wiredump_dev = str = ''
    drv.generate_explicit_type = false
    # response contains only 1 part.
    result = drv.echoNestedStruct(SOAPStructStruct.new("str", 1, 1.0, SOAPStruct.new("str", 1, 1.0)))[0]
    assert_equal('str', result.varString)
    assert_equal(1, result.varInt)
    assert_equal(1.0, result.varFloat)
    assert_equal('str', result.structItem.varString)
    assert_equal(1, result.structItem.varInt)
    assert_equal(1.0, result.structItem.varFloat)
    assert_equal(ECHO_NESTED_STRUCT_REQUEST, parse_requestxml(str))
    assert_equal(ECHO_NESTED_STRUCT_RESPONSE, parse_responsexml(str))
  end

  def test_stub_echoNestedStruct_nil
    drv = SoapTestPortTypeRpcLit.new("http://localhost:#{Port}/")
    drv.wiredump_dev = str = ''
    drv.generate_explicit_type = false
    # response contains only 1 part.
    result = drv.echoNestedStruct(SOAPStructStruct.new("str", nil, 1.0, SOAPStruct.new("str", ::SOAP::SOAPNil.new, 1.0)))[0]
    assert(result.respond_to?(:varInt))
    assert(result.respond_to?(:varString))
    assert_equal(ECHO_NESTED_STRUCT_REQUEST_NIL, parse_requestxml(str),
      [ECHO_NESTED_STRUCT_REQUEST_NIL, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_NESTED_STRUCT_RESPONSE_NIL, parse_responsexml(str))
  end

  ECHO_STRUCT_ARRAY_REQUEST =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStructArray xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <inputStructArray xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <n2:structItem>
          <varString>str</varString>
          <varInt>2</varInt>
          <varFloat>+2.1</varFloat>
        </n2:structItem>
        <n2:structItem>
          <varString>str</varString>
          <varInt>2</varInt>
          <varFloat>+2.1</varFloat>
        </n2:structItem>
      </inputStructArray>
    </n1:echoStructArray>
  </env:Body>
</env:Envelope>]

  ECHO_STRUCT_ARRAY_RESPONSE =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:echoStructArrayResponse xmlns:n1="http://soapbuilders.org/rpc-lit-test">
      <n1:return xmlns:n2="http://soapbuilders.org/rpc-lit-test/types">
        <n2:structItem>
          <varString>str</varString>
          <varInt>2</varInt>
          <varFloat>+2.1</varFloat>
        </n2:structItem>
        <n2:structItem>
          <varString>str</varString>
          <varInt>2</varInt>
          <varFloat>+2.1</varFloat>
        </n2:structItem>
      </n1:return>
    </n1:echoStructArrayResponse>
  </env:Body>
</env:Envelope>]

  def test_wsdl_echoStructArray
    wsdl = pathname('test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = str = ''
    @client.generate_explicit_type = false
    # response contains only 1 part.
    e = SOAPStruct.new("str", 2, 2.1)
    result = @client.echoStructArray(ArrayOfSOAPStruct[e, e])
    assert_equal(ECHO_STRUCT_ARRAY_REQUEST, parse_requestxml(str),
      [ECHO_STRUCT_ARRAY_REQUEST, parse_requestxml(str)].join("\n\n"))
    assert_equal(ECHO_STRUCT_ARRAY_RESPONSE, parse_responsexml(str))
  end

  def test_stub_echoStructArray
    drv = SoapTestPortTypeRpcLit.new("http://localhost:#{Port}/")
    drv.wiredump_dev = str = ''
    drv.generate_explicit_type = false
    # response contains only 1 part.
    e = SOAPStruct.new("str", 2, 2.1)
    result = drv.echoStructArray(ArrayOfSOAPStruct[e, e])
    assert_equal(ECHO_STRUCT_ARRAY_REQUEST, parse_requestxml(str))
    assert_equal(ECHO_STRUCT_ARRAY_RESPONSE, parse_responsexml(str))
  end

  def parse_requestxml(str)
    str.split(/\r?\n\r?\n/)[3]
  end

  def parse_responsexml(str)
    str.split(/\r?\n\r?\n/)[6]
  end
end


end; end

end
