require 'test/unit'
require 'soap/marshal'
require 'soap/rpc/standaloneServer'
require 'soap/rpc/driver'


module SOAP


class TestMap < Test::Unit::TestCase

  class CustomHashFactory < SOAP::Mapping::Factory
    def initialize(itemname)
      @itemname = itemname
    end

    def obj2soap(soap_class, obj, info, map)
      soap_obj = SOAP::SOAPStruct.new(SOAP::Mapping::MapQName)
      mark_marshalled_obj(obj, soap_obj)
      obj.each do |key, value|
        elem = SOAP::SOAPStruct.new
        elem.add('key', Mapping._obj2soap(key, map))
        elem.add('value', Mapping._obj2soap(value, map))
        soap_obj.add(@itemname, elem)
      end
      soap_obj
    end

    def soap2obj(obj_class, node, info, map)
      false
    end
  end

  Map = SOAP::Mapping::Registry.new
  Map.add(Hash, SOAP::SOAPStruct, CustomHashFactory.new('customname'))

  Port = 17171

  class MapServer < SOAP::RPC::StandaloneServer
    def initialize(*arg)
      super
      add_rpc_method(self, 'echo', 'map')
      add_rpc_method(self, 'setmap')
    end

    def echo(map)
      map
    end

    def setmap
      self.mapping_registry = Map
      nil
    end
  end

  def setup
    @server = MapServer.new(self.class.name, nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      @server.start
    }
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint)
    @client.add_rpc_method('echo', 'map')
    @client.add_rpc_method('setmap')
    @client.wiredump_dev = STDOUT if $DEBUG
  end

  def teardown
    @server.shutdown if @server
    if @t
      @t.kill
      @t.join
    end
    @client.reset_stream if @client
  end

  def test_map
    h = {'a' => 1, 'b' => 2}
    soap = SOAP::Marshal.marshal(h)
    puts soap if $DEBUG
    obj = SOAP::Marshal.unmarshal(soap)
    assert_equal(h, obj)
    #
    soap = SOAP::Marshal.marshal(h, Map)
    puts soap if $DEBUG
    obj = SOAP::Marshal.unmarshal(soap, Map)
    assert_equal(h, obj)
  end

  def test_rpc
    h = {'a' => 1, 'b' => 2}
    @client.wiredump_dev = str = ''
    assert_equal(h, @client.echo(h))
    assert_equal(0, str.scan(/customname/).size)
    #
    @client.setmap
    @client.wiredump_dev = str = ''
    assert_equal(h, @client.echo(h))
    assert_equal(4, str.scan(/customname/).size)
    #
    @client.mapping_registry = Map
    @client.wiredump_dev = str = ''
    assert_equal(h, @client.echo(h))
    assert_equal(8, str.scan(/customname/).size)
  end
end


end
