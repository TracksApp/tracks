require 'soap/mapping'


module SOAPBuildersInteropResult
extend SOAP


InterfaceNS = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInteropResult/0.0.1'
TypeNS = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInteropResult/type/0.0.1'


class Endpoint
  include SOAP::Marshallable

  attr_accessor :processorName, :processorVersion, :endpointName, :uri, :wsdl

  def initialize( endpointName = nil, uri = nil, wsdl = nil )
    @processorName = 'unknown'
    @processorVersion = nil
    @endpointName = endpointName
    @uri = uri
    @wsdl = wsdl
  end

  def name
    if @endpointName
      @endpointName
    elsif @processorVersion
      "#{ @processorName }-#{ @processorVersion }"
    else
      "#{ @processorName }"
    end
  end
end


class TestResult
  include SOAP::Marshallable

  attr_accessor :testName, :result, :comment, :wiredump

  def initialize( testName, result, comment = nil, wiredump = nil )
    @testName = testName
    @result = result
    @comment = comment
    @wiredump = wiredump
  end
end


class InteropResults
  include SOAP::Marshallable
  include Enumerable

  attr_accessor :dateTime, :server, :client

  def initialize( client = nil, server = nil )
    @dateTime = Time.now
    @server = server
    @client = client
    @testResults = []
  end

  def add( testResult )
    @testResults << testResult
  end

  def clear
    @testResults.clear
  end

  def each
    @testResults.each do | item |
      yield( item )
    end
  end

  def size
    @testResults.size
  end
end


Methods = [
  [ 'addResults', ['in', 'interopResults' ]],
  [ 'deleteResults', ['in', 'client'], ['in', 'server']],
]



MappingRegistry = SOAP::Mapping::Registry.new

MappingRegistry.set(
  ::SOAPBuildersInteropResult::Endpoint,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  [ XSD::QName.new(TypeNS, 'Endpoint') ]
)

MappingRegistry.set(
  ::SOAPBuildersInteropResult::TestResult,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  [ XSD::QName.new(TypeNS, 'TestResult') ]
)
MappingRegistry.set(
  ::SOAPBuildersInteropResult::InteropResults,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  [ XSD::QName.new(TypeNS, 'InteropResults') ]
)


end
