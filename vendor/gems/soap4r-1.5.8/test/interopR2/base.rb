require 'soap/soap'
require 'soap/mapping'


InterfaceNS = 'http://soapinterop.org/'
TypeNS = 'http://soapinterop.org/xsd'
ApacheNS = 'http://xml.apache.org/xml-soap'


module SOAPBuildersInterop
extend SOAP


MethodsBase = [
  ['echoVoid'],
  ['echoString',
    ['in', 'inputString', nil], ['retval', 'return', nil]],
  ['echoStringArray',
    ['in', 'inputStringArray', nil], ['retval', 'return', nil]],
  ['echoInteger',
    ['in', 'inputInteger', nil], ['retval', 'return', nil]],
  ['echoIntegerArray',
    ['in', 'inputIntegerArray', nil], ['retval', 'return', nil]],
  ['echoFloat',
    ['in', 'inputFloat', nil], ['retval', 'return', nil]],
  ['echoFloatArray',
    ['in', 'inputFloatArray', nil], ['retval', 'return', nil]],
  ['echoStruct',
    ['in', 'inputStruct', nil], ['retval', 'return', nil]],
  ['echoStructArray',
    ['in', 'inputStructArray', nil], ['retval', 'return', nil]],
  ['echoDate',
    ['in', 'inputDate', nil], ['retval', 'return', nil]],
  ['echoBase64',
    ['in', 'inputBase64', nil], ['retval', 'return', nil]],
  ['echoHexBinary',
    ['in', 'inputHexBinary', nil], ['retval', 'return', nil]],
  ['echoBoolean',
    ['in', 'inputBoolean', nil], ['retval', 'return', nil]],
  ['echoDecimal',
    ['in', 'inputDecimal', nil], ['retval', 'return', nil]],
  ['echoMap',
    ['in', 'inputMap', nil], ['retval', 'return', nil]],
  ['echoMapArray',
    ['in', 'inputMapArray', nil], ['retval', 'return', nil]],

  ['echoDouble',
    ['in', 'inputDouble', nil], ['retval', 'return', nil]],
  ['echoXSDDateTime',
    ['in', 'inputXSDDateTime', nil], ['retval', 'return', nil]],
  ['echoXSDDate',
    ['in', 'inputXSDDate', nil], ['retval', 'return', nil]],
  ['echoXSDTime',
    ['in', 'inputXSDTime', nil], ['retval', 'return', nil]],
]

MethodsGroupB = [
  ['echoStructAsSimpleTypes',
    ['in', 'inputStruct', nil], ['out', 'outputString', nil], ['out', 'outputInteger', nil], ['out', 'outputFloat', nil]],
  ['echoSimpleTypesAsStruct',
    ['in', 'inputString', nil], ['in', 'inputInteger', nil], ['in', 'inputFloat', nil], ['retval', 'return', nil]],
  ['echo2DStringArray',
    ['in', 'input2DStringArray', nil], ['retval', 'return', nil]],
  ['echoNestedStruct',
    ['in', 'inputStruct', nil], ['retval', 'return', nil]],
  ['echoNestedArray',
    ['in', 'inputStruct', nil], ['retval', 'return', nil]],
]

MethodsPolyMorph = [
  ['echoPolyMorph',
    ['in', 'inputPolyMorph', nil], ['retval', 'return', nil]],
  ['echoPolyMorphStruct',
    ['in', 'inputPolyMorphStruct', nil], ['retval', 'return', nil]],
  ['echoPolyMorphArray',
    ['in', 'inputPolyMorphArray', nil], ['retval', 'return', nil]],
]


module FloatSupport
  def floatEquals( lhs, rhs )
    lhsVar = lhs.is_a?( SOAP::SOAPFloat )? lhs.data : lhs
    rhsVar = rhs.is_a?( SOAP::SOAPFloat )? rhs.data : rhs
    lhsVar == rhsVar
  end
end

class SOAPStruct
  include SOAP::Marshallable
  include FloatSupport

  attr_accessor :varInt, :varFloat, :varString

  def initialize( varInt, varFloat, varString )
    @varInt = varInt
    @varFloat = varFloat ? SOAP::SOAPFloat.new( varFloat ) : nil
    @varString = varString
  end

  def ==( rhs )
    r = if rhs.is_a?( self.class )
	( self.varInt == rhs.varInt &&
	floatEquals( self.varFloat, rhs.varFloat ) &&
	self.varString == rhs.varString )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }"
  end
end


class SOAPStructStruct
  include SOAP::Marshallable
  include FloatSupport

  attr_accessor :varInt, :varFloat, :varString, :varStruct

  def initialize( varInt, varFloat, varString, varStruct = nil )
    @varInt = varInt
    @varFloat = varFloat ? SOAP::SOAPFloat.new( varFloat ) : nil
    @varString = varString
    @varStruct = varStruct
  end

  def ==( rhs )
    r = if rhs.is_a?( self.class )
	( self.varInt == rhs.varInt &&
	floatEquals( self.varFloat, rhs.varFloat ) &&
	self.varString == rhs.varString &&
	self.varStruct == rhs.varStruct )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }:#{ varStruct }"
  end
end


class PolyMorphStruct
  include SOAP::Marshallable

  attr_reader :varA, :varB, :varC

  def initialize( varA, varB, varC )
    @varA = varA
    @varB = varB
    @varC = varC
  end

  def ==( rhs )
    r = if rhs.is_a?( self.class )
	( self.varA == rhs.varA &&
	self.varB == rhs.varB &&
	self.varC == rhs.varC )
      else
	false
      end
    r
  end

  def to_s
    "#{ varA }:#{ varB }:#{ varC }"
  end
end


class SOAPArrayStruct
  include SOAP::Marshallable
  include FloatSupport

  attr_accessor :varInt, :varFloat, :varString, :varArray

  def initialize( varInt, varFloat, varString, varArray = nil )
    @varInt = varInt
    @varFloat = varFloat ? SOAP::SOAPFloat.new( varFloat ) : nil
    @varString = varString
    @varArray = varArray
  end

  def ==( rhs )
    r = if rhs.is_a?( self.class )
	( self.varInt == rhs.varInt &&
	floatEquals( self.varFloat, rhs.varFloat ) &&
	self.varString == rhs.varString &&
	self.varArray == rhs.varArray )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }:#{ varArray }"
  end
end


class StringArray < Array; end
class IntArray < Array; end
class FloatArray < Array; end
class SOAPStructArray < Array; end
class SOAPMapArray < Array; end
class ArrayOfanyType < Array; end


MappingRegistry = SOAP::Mapping::Registry.new

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  { :type => XSD::QName.new( TypeNS, "SOAPStruct" ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStructStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  { :type => XSD::QName.new( TypeNS, "SOAPStructStruct" ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::PolyMorphStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  { :type => XSD::QName.new( TypeNS, "PolyMorphStruct" ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPArrayStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::Mapping::Registry::TypedStructFactory,
  { :type => XSD::QName.new( TypeNS, "SOAPArrayStruct" ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::StringArray,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::QName.new( XSD::Namespace, XSD::StringLiteral ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::IntArray,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::QName.new( XSD::Namespace, XSD::IntLiteral ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::FloatArray,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::QName.new( XSD::Namespace, XSD::FloatLiteral ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStructArray,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::QName.new( TypeNS, 'SOAPStruct' ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPMapArray,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::QName.new( ApacheNS, 'Map' ) }
)

MappingRegistry.set(
  ::SOAPBuildersInterop::ArrayOfanyType,
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::Registry::TypedArrayFactory,
  { :type => XSD::AnyTypeName }
)


end
