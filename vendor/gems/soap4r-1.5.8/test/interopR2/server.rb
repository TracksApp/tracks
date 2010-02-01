#!/usr/bin/env ruby

$:.unshift(".")

#$KCODE = "UTF8"      # Set $KCODE before loading 'soap/xmlparser'.
#$KCODE = "EUC"
$KCODE = "SJIS"

require 'soap/rpc/standaloneServer'
require 'base'
require 'xsd/xmlparser/rexmlparser'

class InteropApp < SOAP::RPC::StandaloneServer
  include SOAP

  def initialize(*arg)
    super(*arg)
    self.mapping_registry = SOAPBuildersInterop::MappingRegistry
    self.level = Logger::Severity::ERROR
  end

  def on_init
    (SOAPBuildersInterop::MethodsBase + SOAPBuildersInterop::MethodsGroupB + SOAPBuildersInterop::MethodsPolyMorph).each do |name, *params|
      add_method(self, name, params)
    end
  end

  # In echoVoid, 'retval' is not defined.  So nothing will be returned.
  def echoVoid
    return SOAP::RPC::SOAPVoid.new
  end

  def echoBoolean(inputBoolean)
    inputBoolean
  end

  def echoString(inputString)
    clone(inputString)
  end

  def echoStringArray(inputStringArray)
    clone(inputStringArray)
  end

  def echoInteger(inputInteger)
    SOAP::SOAPInt.new(clone(inputInteger))
  end

  def echoIntegerArray(inputIntegerArray)
    clone(inputIntegerArray)
  end

  # Float is mapped to SOAPDouble by default.
  def echoFloat(inputFloat)
    SOAP::SOAPFloat.new(inputFloat)
  end

  def echoDecimal(inputDecimal)
    SOAP::SOAPDecimal.new(clone(inputDecimal))
  end

  def echoFloatArray(inputFloatArray)
    outArray = SOAPBuildersInterop::FloatArray.new
    inputFloatArray.each do |f|
      outArray << SOAPFloat.new(f)
    end
    outArray
  end

  def echoStruct(inputStruct)
    clone_Struct(inputStruct)
  end

  def echoStructArray(inputStructArray)
    clone_StructArray(inputStructArray)
  end

  def echoDate(inputDate)
    clone(inputDate)
  end

  def echoBase64(inputBase64)
    o = SOAP::SOAPBase64.new(clone(inputBase64))
    o.as_xsd
    o
  end

  def echoHexBinary(inputHexBinary)
    SOAP::SOAPHexBinary.new(clone(inputHexBinary))
  end

  def echoDouble(inputDouble)
    SOAP::SOAPDouble.new(inputDouble)
  end

  # for Round 2 group B
  def echoStructAsSimpleTypes(inputStruct)
    outputString = inputStruct.varString
    outputInteger = inputStruct.varInt
    outputFloat = inputStruct.varFloat ? SOAPFloat.new(inputStruct.varFloat) : nil
    # retVal is not returned to SOAP client because retVal of this method is
    #   not defined in method definition.
    # retVal, out, out, out
    return nil, outputString, outputInteger, outputFloat
  end

  def echoSimpleTypesAsStruct(inputString, inputInt, inputFloat)
    SOAPBuildersInterop::SOAPStruct.new(inputInt, inputFloat, inputString)
  end

  def echo2DStringArray(ary)
    # In Ruby, M-D Array is converted to Array of Array now.
    mdary = SOAP::Mapping.ary2md(ary, 2, XSD::Namespace, XSD::StringLiteral)
    if mdary.include?(nil)
      mdary.sparse = true
    end
    mdary
  end

  def echoNestedStruct(inputStruct)
    clone_StructStruct(inputStruct)
  end

  def echoNestedArray(inputStruct)
    clone_Struct(inputStruct)
  end

  def echoMap(inputMap)
    clone(inputMap)
  end

  def echoMapArray(inputMapArray)
    clone(inputMapArray)
  end

  def echoPolyMorph(anObject)
    clone(anObject)
  end

  alias echoPolyMorphStruct echoPolyMorph
  alias echoPolyMorphArray echoPolyMorph


  def echoXSDBoolean(inputBoolean)
    inputBoolean
  end

  def echoXSDString(inputString)
    clone(inputString)
  end

  def echoXSDDecimal(inputDecimal)
    SOAP::SOAPDecimal.new(clone(inputDecimal))
  end

  def echoXSDFloat(inputFloat)
    SOAPFloat.new(inputFloat)
  end

  def echoXSDDouble(inputDouble)
    SOAP::SOAPDouble.new(clone(inputDouble))
  end

  def echoXSDDuration(inputDuration)
    SOAP::SOAPDuration.new(clone(inputDuration))
  end

  def echoXSDDateTime(inputXSDDateTime)
    clone(inputXSDDateTime)
  end

  def echoXSDTime(inputXSDTime)
    SOAP::SOAPTime.new(clone(inputXSDTime))
  end

  def echoXSDDate(inputXSDDate)
    SOAP::SOAPDate.new(clone(inputXSDDate))
  end

  def echoXSDgYearMonth(inputGYearMonth)
    SOAP::SOAPgYearMonth.new(clone(inputGYearMonth))
  end

  def echoXSDgYear(inputGYear)
    SOAP::SOAPgYear.new(clone(inputGYear))
  end

  def echoXSDgMonthDay(inputGMonthDay)
    SOAP::SOAPgMonthDay.new(clone(inputGMonthDay))
  end

  def echoXSDgDay(inputGDay)
    SOAP::SOAPgDay.new(clone(inputGDay))
  end

  def echoXSDgMonth(inputGMonth)
    SOAP::SOAPgMonth.new(clone(inputGMonth))
  end

  def echoXSDHexBinary(inputHexBinary)
    SOAP::SOAPHexBinary.new(clone(inputHexBinary))
  end

  def echoXSDBase64(inputBase64)
    o = SOAP::SOAPBase64.new(clone(inputBase64))
    o.as_xsd
    o
  end

  def echoXSDanyURI(inputAnyURI)
    clone(inputAnyURI)
  end

  def echoXSDQName(inputQName)
    SOAP::SOAPQName.new(clone(inputQName))
  end

  def echoXSDInteger(inputXSDInteger)
    clone(inputXSDInteger)
  end

  def echoXSDLong(inputLong)
    SOAP::SOAPLong.new(clone(inputLong))
  end

  def echoXSDInt(inputInt)
    SOAP::SOAPInt.new(clone(inputInteger))
  end

  def echoPolyMorph(anObject)
    clone(anObject)
  end

  alias echoPolyMorphStruct echoPolyMorph
  alias echoPolyMorphArray echoPolyMorph

private

  def clone(obj)
    begin
      return Marshal.load(Marshal.dump(obj))
    rescue TypeError
      return obj
    end
  end

  def clone_Struct(struct)
    result = clone(struct)
    result.varFloat = SOAPFloat.new(struct.varFloat) if struct.varFloat
    result
  end

  def clone_StructArray(structArray)
    result = clone(structArray)
    result.map { |ele|
      ele.varFloat = SOAPFloat.new(ele.varFloat) if ele.varFloat
    }
    result
  end

  def clone_StructStruct(structStruct)
    result = clone(structStruct)
    result.varFloat = SOAPFloat.new(structStruct.varFloat) if structStruct.varFloat
    if struct = result.varStruct
      struct.varFloat = SOAPFloat.new(struct.varFloat) if struct.varFloat
    end
    result
  end
end

if __FILE__ == $0
  svr = InteropApp.new('InteropApp', InterfaceNS, '0.0.0.0', 10080)
  trap("INT") { svr.shutdown }
  svr.start
end
