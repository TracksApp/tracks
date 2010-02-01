require 'test/unit'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'
require 'soap/filter'


module SOAP
module Filter


class TestFilter < Test::Unit::TestCase
  Port = 17171
  PortName = 'http://tempuri.org/filterPort'

  class FilterTestServer < SOAP::RPC::StandaloneServer
    class Servant
      def self.create
	new
      end

      def echo(amt)
        amt
      end
    end

    class ServerFilter1 < SOAP::Filter::Handler
      # 15 -> 30
      def on_outbound(envelope, opt)
        unless envelope.body.is_fault
          node = envelope.body.root_node
          node.retval = SOAPInt.new(node.retval.data * 2)
          node.elename = XSD::QName.new(nil, 'return')
        end
        envelope
      end

      # 4 -> 5
      def on_inbound(xml, opt)
        xml = xml.sub(/4/, '5')
        xml
      end
    end

    class ServerFilter2 < SOAP::Filter::Handler
      # 5 -> 15
      def on_outbound(envelope, opt)
        unless envelope.body.is_fault
          node = envelope.body.root_node
          node.retval = SOAPInt.new(node.retval.data + 10)
          node.elename = XSD::QName.new(nil, 'return')
        end
        envelope
      end

      # 5 -> 6
      def on_inbound(xml, opt)
        xml = xml.sub(/5/, '6')
        xml
      end
    end

    def initialize(*arg)
      super
      add_rpc_servant(Servant.new, PortName)
      self.filterchain << ServerFilter1.new
      self.filterchain << ServerFilter2.new
    end
  end

  def setup
    @endpoint = "http://localhost:#{Port}/"
    setup_server
    setup_client
  end

  def setup_server
    @server = FilterTestServer.new(self.class.name, nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      @server.start
    }
  end

  def setup_client
    @client = SOAP::RPC::Driver.new(@endpoint, PortName)
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method('echo', 'amt')
  end

  def teardown
    teardown_server if @server
    teardown_client if @client
  end

  def teardown_server
    @server.shutdown
    @t.kill
    @t.join
  end

  def teardown_client
    @client.reset_stream
  end

  class ClientFilter1 < SOAP::Filter::Handler
    # 1 -> 2
    def on_outbound(envelope, opt)
      param = envelope.body.root_node.inparam
      param["amt"] = SOAPInt.new(param["amt"].data + 1)
      param["amt"].elename = XSD::QName.new(nil, 'amt')
      envelope
    end

    # 31 -> 32
    def on_inbound(xml, opt)
      xml = xml.sub(/31/, '32')
      xml
    end
  end

  class ClientFilter2 < SOAP::Filter::Handler
    # 2 -> 4
    def on_outbound(envelope, opt)
      param = envelope.body.root_node.inparam
      param["amt"] = SOAPInt.new(param["amt"].data * 2)
      param["amt"].elename = XSD::QName.new(nil, 'amt')
      envelope
    end

    # 30 -> 31
    def on_inbound(xml, opt)
      xml = xml.sub(/30/, '31')
      xml
    end
  end

  def test_call
    @client.filterchain << ClientFilter1.new
    @client.filterchain << ClientFilter2.new
    assert_equal(32, @client.echo(1))
  end
end


end
end
