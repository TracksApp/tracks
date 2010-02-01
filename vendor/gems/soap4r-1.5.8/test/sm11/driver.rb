require 'classDef'
require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'

class Sm11PortType
  MappingRegistry = SOAP::RPCUtils::MappingRegistry.new

  MappingRegistry.set(
    C_struct,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "http://dopg.gr.jp/sm11.xsd", "C_struct" ]
  )
  MappingRegistry.set(
    ArrayOfboolean,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "boolean" ]
  )
  MappingRegistry.set(
    ArrayOfshort,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "short" ]
  )
  MappingRegistry.set(
    ArrayOfint,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "int" ]
  )
  MappingRegistry.set(
    ArrayOflong,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "long" ]
  )
  MappingRegistry.set(
    ArrayOffloat,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "float" ]
  )
  MappingRegistry.set(
    ArrayOfdouble,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "double" ]
  )
  MappingRegistry.set(
    ArrayOfstring,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://www.w3.org/2001/XMLSchema", "string" ]
  )
  MappingRegistry.set(
    F_struct,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "http://dopg.gr.jp/sm11.xsd", "F_struct" ]
  )
  MappingRegistry.set(
    ArrayOfC_struct,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "http://dopg.gr.jp/sm11.xsd", "C_struct" ]
  )

  Methods = [
    [ "op0", "op0", [  ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op1", "op1", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op4", "op4", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op5", "op5", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op6", "op6", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op7", "op7", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op8", "op8", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op9", "op9", [ [ "in", "arg0" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op11", "op11", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op14", "op14", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op15", "op15", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op16", "op16", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op17", "op17", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op18", "op18", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op19", "op19", [ [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op21", "op21", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op24", "op24", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op25", "op25", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op26", "op26", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op27", "op27", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op28", "op28", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op29", "op29", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op30", "op30", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op31", "op31", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op34", "op34", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op35", "op35", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op36", "op36", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op37", "op37", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op38", "op38", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op39", "op39", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op40", "op40", [ [ "in", "arg0" ], [ "in", "arg1" ], [ "in", "arg2" ], [ "in", "arg3" ], [ "in", "arg4" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op41", "op41", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op42", "op42", [ [ "in", "arg0" ], [ "retval", "result" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "op43", "op43", [ [ "in", "arg0" ], [ "in", "arg1" ] ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "excop1", "excop1", [  ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "excop2", "excop2", [  ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "excop3", "excop3", [  ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ],
    [ "excop4", "excop4", [  ], "http://dopg.gr.jp/sm11", "http://dopg.gr.jp/sm11" ]
  ]

  attr_reader :endpointUrl
  attr_reader :proxyUrl

  def initialize( endpointUrl, proxyUrl = nil )
    @endpointUrl = endpointUrl
    @proxyUrl = proxyUrl
    @httpStreamHandler = SOAP::HTTPPostStreamHandler.new( @endpointUrl,
      @proxyUrl )
    @proxy = SOAP::SOAPProxy.new( nil, @httpStreamHandler, nil )
    @proxy.allowUnqualifiedElement = true
    @mappingRegistry = MappingRegistry
    addMethod
  end

  def setWireDumpDev( dumpDev )
    @httpStreamHandler.dumpDev = dumpDev
  end

  def setDefaultEncodingStyle( encodingStyle )
    @proxy.defaultEncodingStyle = encodingStyle
  end

  def getDefaultEncodingStyle
    @proxy.defaultEncodingStyle
  end

  def call( methodName, *params )
    # Convert parameters
    params.collect! { | param |
      SOAP::RPCUtils.obj2soap( param, @mappingRegistry )
    }

    # Then, call @proxy.call like the following.
    header, body = @proxy.call( nil, methodName, *params )

    # Check Fault.
    begin
      @proxy.checkFault( body )
    rescue SOAP::FaultError => e
      SOAP::RPCUtils.fault2exception( e, @mappingRegistry )
    end

    ret = body.response ?
      SOAP::RPCUtils.soap2obj( body.response, @mappingRegistry ) : nil
    if body.outParams
      outParams = body.outParams.collect { | outParam |
	SOAP::RPCUtils.soap2obj( outParam )
      }
      return [ ret ].concat( outParams )
    else
      return ret
    end
  end

private

  def addMethod
    Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      @proxy.addMethodAs( methodNameAs, methodName, params, soapAction,
	namespace )
      addMethodInterface( methodNameAs, params )
    end
  end

  def addMethodInterface( name, params )
    self.instance_eval <<-EOD
      def #{ name }( *params )
	call( "#{ name }", *params )
      end
    EOD
  end
end
