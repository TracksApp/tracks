require 'test/unit'
require 'soap/rpc/standaloneServer'
require 'soap/rpc/driver'
require 'soap/header/handler'


module SOAP


class TestNil < Test::Unit::TestCase
  Port = 17171

  class NilServer < SOAP::RPC::StandaloneServer
    def initialize(*arg)
      super
      add_method(self, 'nop')
    end

    def nop
      1
    end
  end

  def setup
    @server = NilServer.new(self.class.name, nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      @server.start
    }
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint)
    @client.add_rpc_method('nop')
  end

  def teardown
    @server.shutdown if @server
    if @t
      @t.kill
      @t.join
    end
    @client.reset_stream if @client
  end

  require 'rexml/document'
  # emulates SOAP::Lite's nil request
  def test_soaplite_nil
    body = SOAP::SOAPBody.new(REXML::Document.new(<<-__XML__))
      <nop xsi:nil="true"/>
    __XML__
    @client.wiredump_dev = STDOUT if $DEBUG
    header, body = @client.invoke(nil, body)
    assert_equal(1, body.root_node["return"].data)
  end
end


end
