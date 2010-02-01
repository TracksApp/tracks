require 'test/unit'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


if defined?(HTTPClient)

module WSDL


class TestQualified < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'http://www50.brinkster.com/vbfacileinpt/np'

    def on_init
      add_document_method(
        self,
        Namespace + '/GetPrimeNumbers',
        'GetPrimeNumbers',
        XSD::QName.new(Namespace, 'GetPrimeNumbers'),
        XSD::QName.new(Namespace, 'GetPrimeNumbersResponse')
      )
    end

    def GetPrimeNumbers(arg)
      nil
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))
  Port = 17171

  def setup
    setup_server
    setup_clientdef
    @client = nil
  end

  def teardown
    teardown_server if @server
    unless $DEBUG
      File.unlink(pathname('default.rb'))
      File.unlink(pathname('defaultMappingRegistry.rb'))
      File.unlink(pathname('defaultDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:lp", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_clientdef
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      gen = WSDL::SOAP::WSDL2Ruby.new
      gen.location = pathname("np.wsdl")
      gen.basedir = DIR
      gen.logger.level = Logger::FATAL
      gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
      gen.opt['classdef'] = nil
      gen.opt['mapping_registry'] = nil
      gen.opt['driver'] = nil
      gen.opt['force'] = true
      gen.run
      require 'default.rb'
    ensure
      $".delete('default.rb')
      Dir.chdir(backupdir)
    end
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  LOGIN_REQUEST_QUALIFIED =
%q[<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:GetPrimeNumbers xmlns:n1="http://www50.brinkster.com/vbfacileinpt/np">
      <Min>2</Min>
      <n1:Max>10</n1:Max>
    </n1:GetPrimeNumbers>
  </env:Body>
</env:Envelope>]

  def test_wsdl
    wsdl = File.join(DIR, 'np.wsdl')
    @client = nil
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    ensure
      Dir.chdir(backupdir)
    end
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = str = ''
    @client.GetPrimeNumbers(:Min => 2, :Max => 10)
    assert_equal(LOGIN_REQUEST_QUALIFIED, parse_requestxml(str),
      [LOGIN_REQUEST_QUALIFIED, parse_requestxml(str)].join("\n\n"))
  end

  include ::SOAP
  def test_naive
    TestUtil.require(DIR, 'defaultDriver.rb', 'defaultMappingRegistry.rb', 'default.rb')
    @client = PnumSoap.new("http://localhost:#{Port}/")

    @client.wiredump_dev = str = ''
    @client.getPrimeNumbers(GetPrimeNumbers.new(2, 10))
    assert_equal(LOGIN_REQUEST_QUALIFIED, parse_requestxml(str),
      [LOGIN_REQUEST_QUALIFIED, parse_requestxml(str)].join("\n\n"))
  end

  def parse_requestxml(str)
    str.split(/\r?\n\r?\n/)[3]
  end
end


end

end
