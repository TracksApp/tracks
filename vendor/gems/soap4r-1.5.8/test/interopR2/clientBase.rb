$KCODE = 'EUC'

require 'logger'
require 'soap/rpc/driver'
require 'soap/mapping'
require 'base'
require 'interopResultBase'

include SOAP
include SOAPBuildersInterop

$soapAction = 'http://soapinterop.org/'
$testResultServer = 'http://dev.ctor.org/soapsrv'
$testResultDrv = SOAP::RPC::Driver.new($testResultServer,
  SOAPBuildersInteropResult::InterfaceNS)

SOAPBuildersInteropResult::Methods.each do |name, *params|
  $testResultDrv.add_rpc_operation(
      XSD::QName.new(SOAPBuildersInteropResult::InterfaceNS, name),
      nil, name, params)
end

client = SOAPBuildersInteropResult::Endpoint.new
client.processorName = 'SOAP4R'
client.processorVersion = '1.5'
client.uri = '*:*'
client.wsdl = "#{$wsdlBase} #{$wsdlGroupB}"

server = SOAPBuildersInteropResult::Endpoint.new
server.endpointName = $serverName
server.uri = $server || "#{ $serverBase }, #{ $serverGroupB }"
server.wsdl = "#{$wsdlBase} #{$wsdlGroupB}"

$testResults = SOAPBuildersInteropResult::InteropResults.new(client, server)

$wireDumpDev = ''
def $wireDumpDev.close; end

$wireDumpLogFile = STDERR


###
## Method definition.
#
def methodDef(drv)
  drv.soapaction = $soapAction
  methodDefBase(drv)
  methodDefGroupB(drv)
end

def methodDefBase(drv)
  SOAPBuildersInterop::MethodsBase.each do |name, *params|
    drv.add_rpc_operation(
      XSD::QName.new(InterfaceNS, name), $soapAction, name, params)
  end
end

def methodDefGroupB(drv)
  SOAPBuildersInterop::MethodsGroupB.each do |name, *params|
    drv.add_rpc_operation(
      XSD::QName.new(InterfaceNS, name), $soapAction, name, params)
  end
end


###
## Helper function
#
class Float
  Precision = 5

  def ==(rhs)
    if rhs.is_a?(Float)
      if self.nan? and rhs.nan?
	true
      elsif self.infinite? == rhs.infinite?
	true
      elsif (rhs - self).abs <= (10 ** (- Precision))
	true
      else
	false
      end
    else
      false
    end
  end
end

def assert(expected, actual)
  if expected == actual
    'OK'
  else
    "Expected = " << expected.inspect << "  //  Actual = " << actual.inspect
  end
end

def setWireDumpLogFile(postfix = "")
  logFilename = File.basename($0).sub(/\.rb$/, '') << postfix << '.log'
  f = File.open(logFilename, 'w')
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
  $wireDumpLogFile = f
end

def getWireDumpLogFileBase(postfix = "")
  File.basename($0).sub(/\.rb$/, '') + postfix
end

def getIdObj(obj)
  case obj
  when Array
    obj.collect { |ele|
      getIdObj(ele)
    }
  else
    # String#== compares content of args.
    "#{ obj.class }##{ obj.__id__ }"
  end
end

def dumpTitle(title)
  p title
  $wireDumpLogFile << "##########\n# " << title << "\n\n"
end

def dumpNormal(title, expected, actual)
  result = assert(expected, actual)
  if result == 'OK'
    dumpResult(title, true, nil)
  else
    dumpResult(title, false, result)
  end
end

def dumpException(title)
  result = "Exception: #{ $! } (#{ $!.class})\n" << $@.join("\n")
  dumpResult(title, false, result)
end

def dumpResult(title, result, resultStr)
  $testResults.add(
    SOAPBuildersInteropResult::TestResult.new(
      title,
      result,
      resultStr,
      $wireDumpDev.dup
    )
  )
  $wireDumpLogFile << "Result: #{ resultStr || 'OK' }\n\n"
  $wireDumpLogFile << $wireDumpDev
  $wireDumpLogFile << "\n"

  $wireDumpDev.replace('')
end

def submitTestResult
  $testResultDrv.addResults($testResults)
end

class FakeFloat < SOAP::SOAPFloat
  def initialize(str)
    super()
    @data = str
  end

  def to_s
    @data.to_s
  end
end

class FakeDateTime < SOAP::SOAPDateTime
  def initialize(str)
    super()
    @data = str
  end

  def to_s
    @data.to_s
  end
end

class FakeDecimal < SOAP::SOAPDecimal
  def initialize(str)
    super()
    @data = str
  end

  def to_s
    @data.to_s
  end
end

class FakeInt < SOAP::SOAPInt
  def initialize(str)
    super()
    @data = str
  end

  def to_s
    @data.to_s
  end
end


###
## Invoke methods.
#
def doTest(drv)
  doTestBase(drv)
  doTestGroupB(drv)
end

def doTestBase(drv)
  setWireDumpLogFile('_Base')
  drv.wiredump_dev = $wireDumpDev
#  drv.wiredump_filebase = getWireDumpLogFileBase('_Base')

  drv.mapping_registry = SOAPBuildersInterop::MappingRegistry

  title = 'echoVoid'
  dumpTitle(title)
  begin
    var =  drv.echoVoid()
    dumpNormal(title, nil, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString'
  dumpTitle(title)
  begin
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (Entity reference)'
  dumpTitle(title)
  begin
    arg = "<>\"& &lt;&gt;&quot;&amp; &amp&amp;><<<"
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (Character reference)'
  dumpTitle(title)
  begin
    arg = "\x20&#x20;\040&#32;\x7f&#x7f;\177&#127;"
    tobe = "    \177\177\177\177"
    var = drv.echoString(SOAP::SOAPRawString.new(arg))
    dumpNormal(title, tobe, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (Leading and trailing whitespace)'
  dumpTitle(title)
  begin
    arg = "   SOAP4R\nInteroperability\nTest   "
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (EUC encoded)'
  dumpTitle(title)
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (EUC encoded) again'
  dumpTitle(title)
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (empty)'
  dumpTitle(title)
  begin
    arg = ''
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (space)'
  dumpTitle(title)
  begin
    arg = ' '
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoString (whitespaces:\r \n \t \r \n \t)'
  dumpTitle(title)
  begin
    arg = "\r \n \t \r \n \t"
    var = drv.echoString(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStringArray'
  dumpTitle(title)
  begin
    arg = StringArray["SOAP4R\n", " Interoperability ", "\tTest\t"]
    var = drv.echoStringArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoStringArray (sparse)'
#  dumpTitle(title)
#  begin
#    arg = [nil, "SOAP4R\n", nil, " Interoperability ", nil, "\tTest\t", nil]
#    soapAry = SOAP::Mapping.ary2soap(arg, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStringArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoStringArray (multi-ref)'
  dumpTitle(title)
  begin
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStringArray (multi-ref: elem1 == elem3)'
  dumpTitle(title)
  begin
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    dumpNormal(title, getIdObj(var[0]), getIdObj(var[2]))
  rescue Exception
    dumpException(title)
  end

  title = 'echoStringArray (empty, multi-ref: elem1 == elem3)'
  dumpTitle(title)
  begin
    str1 = ""
    str2 = ""
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    dumpNormal(title, getIdObj(var[0]), getIdObj(var[2]))
  rescue Exception
    dumpException(title)
  end

#  title = 'echoStringArray (sparse, multi-ref)'
#  dumpTitle(title)
#  begin
#    str = "SOAP4R"
#    arg = StringArray[nil, nil, nil, nil, nil, str, nil, str]
#    soapAry = SOAP::Mapping.ary2soap(arg, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStringArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoInteger (Int: 123)'
  dumpTitle(title)
  begin
    arg = 123
    var = drv.echoInteger(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (Int: 2147483647)'
  dumpTitle(title)
  begin
    arg = 2147483647
    var = drv.echoInteger(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (Int: -2147483648)'
  dumpTitle(title)
  begin
    arg = -2147483648
    var = drv.echoInteger(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (2147483648: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("2147483648")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (-2147483649: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("-2147483649")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (0.0: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("0.0")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (-5.2: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("-5.2")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (0.000000000a: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("0.000000000a")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoInteger (+-5: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeInt.new("+-5")
      var = drv.echoInteger(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoIntegerArray'
  dumpTitle(title)
  begin
    arg = IntArray[1, 2, 3]
    var = drv.echoIntegerArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoIntegerArray (nil)'
#  dumpTitle(title)
#  begin
#    arg = IntArray[nil, nil, nil]
#    var = drv.echoIntegerArray(arg)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoIntegerArray (empty)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPArray.new(SOAP::ValueArrayName, 1, XSD::XSDInt::Type)
    var = drv.echoIntegerArray(arg)
    dumpNormal(title, [], var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoIntegerArray (sparse)'
#  dumpTitle(title)
#  begin
#    arg = [nil, 1, nil, 2, nil, 3, nil]
#    soapAry = SOAP::Mapping.ary2soap(arg, XSD::Namespace, XSD::XSDInt::Type, SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoIntegerArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoFloat'
  dumpTitle(title)
  begin
    arg = 3.14159265358979
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (scientific notation)'
  dumpTitle(title)
  begin
    arg = 12.34e36
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (scientific notation 2)'
  dumpTitle(title)
  begin
    arg = FakeFloat.new("12.34e36")
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, 12.34e36, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (scientific notation 3)'
  dumpTitle(title)
  begin
    arg = FakeFloat.new("12.34E+36")
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, 12.34e36, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (scientific notation 4)'
  dumpTitle(title)
  begin
    arg = FakeFloat.new("-1.4E")
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, 1.4, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (positive lower boundary)'
  dumpTitle(title)
  begin
    arg = 1.4e-45
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (negative lower boundary)'
  dumpTitle(title)
  begin
    arg = -1.4e-45
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (special values: +0)'
  dumpTitle(title)
  begin
    arg = 0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (special values: -0)'
  dumpTitle(title)
  begin
    arg = (-1.0 / (1.0 / 0.0))
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (special values: NaN)'
  dumpTitle(title)
  begin
    arg = 0.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (special values: INF)'
  dumpTitle(title)
  begin
    arg = 1.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (special values: -INF)'
  dumpTitle(title)
  begin
    arg = -1.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (0.000a: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeFloat.new("0.0000000000000000a")
      var = drv.echoFloat(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (00a.0001: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeFloat.new("00a.000000000000001")
      var = drv.echoFloat(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (+-5: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeFloat.new("+-5")
      var = drv.echoFloat(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloat (5_0: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeFloat.new("5_0")
      var = drv.echoFloat(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloatArray'
  dumpTitle(title)
  begin
    arg = FloatArray[SOAPFloat.new(0.0001), SOAPFloat.new(1000.0), SOAPFloat.new(0.0)]
    var = drv.echoFloatArray(arg)
    dumpNormal(title, arg.collect { |ele| ele.data }, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoFloatArray (special values: NaN, INF, -INF)'
  dumpTitle(title)
  begin
    nan = SOAPFloat.new(0.0/0.0)
    inf = SOAPFloat.new(1.0/0.0)
    inf_ = SOAPFloat.new(-1.0/0.0)
    arg = FloatArray[nan, inf, inf_]
    var = drv.echoFloatArray(arg)
    dumpNormal(title, arg.collect { |ele| ele.data }, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoFloatArray (sparse)'
#  dumpTitle(title)
#  begin
#    arg = [nil, nil, 0.0001, 1000.0, 0.0, nil, nil]
#    soapAry = SOAP::Mapping.ary2soap(arg, XSD::Namespace, XSD::FloatLiteral, SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoFloatArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoStruct'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(1, 1.1, "a")
    var = drv.echoStruct(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStruct (nil members)'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(nil, nil, nil)
    var = drv.echoStruct(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructArray'
  dumpTitle(title)
  begin
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    s3 = SOAPStruct.new(3, 3.3, "c")
    arg = SOAPStructArray[s1, s2, s3]
    var = drv.echoStructArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructArray (anyType Array)'
  dumpTitle(title)
  begin
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    s3 = SOAPStruct.new(3, 3.3, "c")
    arg = [s1, s2, s3]
    var = drv.echoStructArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoStructArray (sparse)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    s3 = SOAPStruct.new(3, 3.3, "c")
#    arg = [nil, s1, s2, s3]
#    soapAry = SOAP::Mapping.ary2soap(arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStructArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoStructArray (multi-ref)'
  dumpTitle(title)
  begin
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = SOAPStructArray[s1, s1, s2]
    var = drv.echoStructArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructArray (multi-ref: elem1 == elem2)'
  dumpTitle(title)
  begin
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = SOAPStructArray[s1, s1, s2]
    var = drv.echoStructArray(arg)
    dumpNormal(title, getIdObj(var[0]), getIdObj(var[1]))
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructArray (anyType Array, multi-ref: elem2 == elem3)'
  dumpTitle(title)
  begin
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = [s1, s2, s2]
    var = drv.echoStructArray(arg)
    dumpNormal(title, getIdObj(var[1]), getIdObj(var[2]))
  rescue Exception
    dumpException(title)
  end

#  title = 'echoStructArray (sparse, multi-ref)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    arg = [nil, s1, nil, nil, s2, nil, s2]
#    soapAry = SOAP::Mapping.ary2soap(arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStructArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

#  title = 'echoStructArray (sparse, multi-ref: elem5 == elem7)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    arg = [nil, s1, nil, nil, s2, nil, s2]
#    soapAry = SOAP::Mapping.ary2soap(arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStructArray(soapAry)
#    dumpNormal(title, getIdObj(var[4]), getIdObj(var[6]))
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoStructArray (multi-ref: varString of elem1 == varString of elem2)'
  dumpTitle(title)
  begin
    str1 = "a"
    str2 = "a"
    s1 = SOAPStruct.new(1, 1.1, str1)
    s2 = SOAPStruct.new(2, 2.2, str1)
    s3 = SOAPStruct.new(3, 3.3, str2)
    arg = SOAPStructArray[s1, s2, s3]
    var = drv.echoStructArray(arg)
    dumpNormal(title, getIdObj(var[0].varString), getIdObj(var[1].varString))
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructArray (anyType Array, multi-ref: varString of elem2 == varString of elem3)'
  dumpTitle(title)
  begin
    str1 = "b"
    str2 = "b"
    s1 = SOAPStruct.new(1, 1.1, str2)
    s2 = SOAPStruct.new(2, 2.2, str1)
    s3 = SOAPStruct.new(3, 3.3, str1)
    arg = [s1, s2, s3]
    var = drv.echoStructArray(arg)
    dumpNormal(title, getIdObj(var[1].varString), getIdObj(var[2].varString))
  rescue Exception
    dumpException(title)
  end

#  title = 'echoStructArray (sparse, multi-ref: varString of elem5 == varString of elem7)'
#  dumpTitle(title)
#  begin
#    str1 = "c"
#    str2 = "c"
#    s1 = SOAPStruct.new(1, 1.1, str2)
#    s2 = SOAPStruct.new(2, 2.2, str1)
#    s3 = SOAPStruct.new(3, 3.3, str1)
#    arg = [nil, s1, nil, nil, s2, nil, s3]
#    soapAry = SOAP::Mapping.ary2soap(arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoStructArray(soapAry)
#    dumpNormal(title, getIdObj(var[4].varString), getIdObj(var[6].varString))
#  rescue Exception
#    dumpException(title)
#  end

#  title = 'echoStructArray (2D Array)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    s3 = SOAPStruct.new(3, 3.3, "c")
#    arg = [
#      [s1, nil, s2],
#      [nil, s2, s3],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry)
#
#    var = drv.echoStructArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end
#
#  title = 'echoStructArray (2D Array, sparse)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    s3 = SOAPStruct.new(3, 3.3, "c")
#    arg = [
#      [s1, nil, s2],
#      [nil, s2, s3],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry)
##    md.sparse = true
#
#    var = drv.echoStructArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end
#
#  title = 'echoStructArray (anyType, 2D Array, sparse)'
#  dumpTitle(title)
#  begin
#    s1 = SOAPStruct.new(1, 1.1, "a")
#    s2 = SOAPStruct.new(2, 2.2, "b")
#    s3 = SOAPStruct.new(3, 3.3, "c")
#    arg = [
#      [s1, nil, s2],
#      [nil, s2, s3],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry)
#    md.sparse = true
#
#    var = drv.echoStructArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoDate (now)'
  dumpTitle(title)
  begin
    t = Time.now.gmtime
    arg = DateTime.new(t.year, t.mon, t.mday, t.hour, t.min, t.sec)
    var = drv.echoDate(arg)
    dumpNormal(title, arg.to_s, var.to_s)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (before 1970: 1-01-01T00:00:00Z)'
  dumpTitle(title)
  begin
    t = Time.now.gmtime
    arg = DateTime.new(1, 1, 1, 0, 0, 0)
    var = drv.echoDate(arg)
    dumpNormal(title, arg.to_s, var.to_s)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (after 2038: 2038-12-31T00:00:00Z)'
  dumpTitle(title)
  begin
    t = Time.now.gmtime
    arg = DateTime.new(2038, 12, 31, 0, 0, 0)
    var = drv.echoDate(arg)
    dumpNormal(title, arg.to_s, var.to_s)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (negative: -10-01-01T00:00:00Z)'
  dumpTitle(title)
  begin
    t = Time.now.gmtime
    arg = DateTime.new(-10, 1, 1, 0, 0, 0)
    var = drv.echoDate(arg)
    dumpNormal(title, arg.to_s, var.to_s)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (time precision: msec)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40.012')
    argDate = arg.data
    var = drv.echoDate(arg)
    dumpNormal(title, argDate, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (time precision: long)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40.0000000000123456789012345678900000000000')
    argDate = arg.data
    var = drv.echoDate(arg)
    dumpNormal(title, argDate, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (positive TZ)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40+07:00')
    argNormalized = DateTime.new(2001, 6, 16, 18, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (negative TZ)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (+00:00 TZ)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40+00:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (-00:00 TZ)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40-00:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (min TZ)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('2001-06-16T00:00:01+00:01')
    argNormalized = DateTime.new(2001, 6, 15, 23, 59, 1)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (year > 9999)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('10000-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(10000, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (year < 0)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('-0001-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(0, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (year == -4713)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPDateTime.new('-4713-01-01T12:00:00')
    argNormalized = DateTime.new(-4712, 1, 1, 12, 0, 0)
    var = drv.echoDate(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (year 0000: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDateTime.new("0000-05-18T16:52:20Z")
      var = drv.echoDate(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (year nn: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDateTime.new("05-05-18T16:52:20Z")
      var = drv.echoDate(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (no day part: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDateTime.new("2002-05T16:52:20Z")
      var = drv.echoDate(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (no sec part: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDateTime.new("2002-05-18T16:52Z")
      var = drv.echoDate(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDate (empty: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDateTime.new("")
      var = drv.echoDate(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (xsd:base64Binary)'
  dumpTitle(title)
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new(str)
    arg.as_xsd	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (xsd:base64Binary, empty)'
  dumpTitle(title)
  begin
    str = ""
    arg = SOAP::SOAPBase64.new(str)
    arg.as_xsd	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (SOAP-ENC:base64)'
  dumpTitle(title)
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (\0)'
  dumpTitle(title)
  begin
    str = "\0"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (\0a\0)'
  dumpTitle(title)
  begin
    str = "a\0b\0\0c\0\0\0"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBase64 (-: junk)'
  dumpTitle(title)
  begin
    begin
      arg = SOAP::SOAPBase64.new("dummy")
      arg.instance_eval { @data = '-' }
      var = drv.echoBase64(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary'
  dumpTitle(title)
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary(empty)'
  dumpTitle(title)
  begin
    str = ""
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary(\0)'
  dumpTitle(title)
  begin
    str = "\0"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary(\0a\0)'
  dumpTitle(title)
  begin
    str = "a\0b\0\0c\0\0\0"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary(lower case)'
  dumpTitle(title)
  begin
    str = "lower case"
    arg = SOAP::SOAPHexBinary.new
    arg.set_encoded((str.unpack("H*")[0]).tr('A-F', 'a-f'))
    var = drv.echoHexBinary(arg)
    dumpNormal(title, str, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoHexBinary (0FG7: junk)'
  dumpTitle(title)
  begin
    begin
      arg = SOAP::SOAPHexBinary.new("dummy")
      arg.instance_eval { @data = '0FG7' }
      var = drv.echoHexBinary(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoBoolean (true)'
  dumpTitle(title)
  begin
    arg = true
    var = drv.echoBoolean(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBoolean (false)'
  dumpTitle(title)
  begin
    arg = false
    var = drv.echoBoolean(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoBoolean (junk)'
  dumpTitle(title)
  begin
    begin
      arg = SOAP::SOAPBoolean.new(true)
      arg.instance_eval { @data = 'junk' }
      var = drv.echoBoolean(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (123456)'
  dumpTitle(title)
  begin
    arg = "123456789012345678"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = arg
    dumpNormal(title, normalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (+0.123)'
  dumpTitle(title)
  begin
    arg = "+0.12345678901234567"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = arg.sub(/0$/, '').sub(/^\+/, '')
    dumpNormal(title, normalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (.00000123)'
  dumpTitle(title)
  begin
    arg = ".00000123456789012"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = '0' << arg.sub(/0$/, '')
    dumpNormal(title, normalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (-.00000123)'
  dumpTitle(title)
  begin
    arg = "-.00000123456789012"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = '-0' << arg.sub(/0$/, '').sub(/-/, '')
    dumpNormal(title, normalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (-123.456)'
  dumpTitle(title)
  begin
    arg = "-123456789012345.008"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (-123.)'
  dumpTitle(title)
  begin
    arg = "-12345678901234567."
    normalized = arg.sub(/\.$/, '')
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    dumpNormal(title, normalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (0.000a: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDecimal.new("0.0000000000000000a")
      var = drv.echoDecimal(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (00a.0001: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDecimal.new("00a.000000000000001")
      var = drv.echoDecimal(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (+-5: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDecimal.new("+-5")
      var = drv.echoDecimal(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

  title = 'echoDecimal (5_0: junk)'
  dumpTitle(title)
  begin
    begin
      arg = FakeDecimal.new("5_0")
      var = drv.echoDecimal(arg)
      dumpNormal(title, 'Fault', 'No error occurred.')
    rescue SOAP::RPC::ServerException, SOAP::FaultError
      dumpNormal(title, true, true)
    end
  rescue Exception
    dumpException(title)
  end

if false # unless $noEchoMap

  title = 'echoMap'
  dumpTitle(title)
  begin
    arg = { "a" => 1, "b" => 2 }
    var = drv.echoMap(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoMap (boolean, base64, nil, float)'
  dumpTitle(title)
  begin
    arg = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    var = drv.echoMap(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoMap (multibyte char)'
  dumpTitle(title)
  begin
    arg = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    var = drv.echoMap(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoMap (Struct)'
  dumpTitle(title)
  begin
    obj = SOAPStruct.new(1, 1.1, "a")
    arg = { 1 => obj, 2 => obj }
    var = drv.echoMap(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoMap (multi-ref: value for key "a" == value for key "b")'
  dumpTitle(title)
  begin
    value = "c"
    arg = { "a" => value, "b" => value }
    var = drv.echoMap(arg)
    dumpNormal(title, getIdObj(var["a"]), getIdObj(var["b"]))
  rescue Exception
    dumpException(title)
  end

  title = 'echoMap (Struct, multi-ref: varString of a key == varString of a value)'
  dumpTitle(title)
  begin
    str = ""
    obj = SOAPStruct.new(1, 1.1, str)
    arg = { obj => "1", "1" => obj }
    var = drv.echoMap(arg)
    dumpNormal(title, getIdObj(var.index("1").varString), getIdObj(var.fetch("1").varString))
  rescue Exception
    dumpException(title)
  end

  title = 'echoMapArray'
  dumpTitle(title)
  begin
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    map3 = { "a" => 1, "b" => 2 }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoMapArray (boolean, base64, nil, float)'
  dumpTitle(title)
  begin
    map1 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map2 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map3 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoMapArray (sparse)'
#  dumpTitle(title)
#  begin
#    map1 = { "a" => 1, "b" => 2 }
#    map2 = { "a" => 1, "b" => 2 }
#    map3 = { "a" => 1, "b" => 2 }
#    arg = [nil, nil, map1, nil, map2, nil, map3, nil, nil]
#    soapAry = SOAP::Mapping.ary2soap(arg, ApacheNS, "Map", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoMapArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoMapArray (multibyte char)'
  dumpTitle(title)
  begin
    map1 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map2 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map3 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echoMapArray (sparse, multi-ref)'
#  dumpTitle(title)
#  begin
#    map1 = { "a" => 1, "b" => 2 }
#    map2 = { "a" => 1, "b" => 2 }
#    arg = [nil, nil, map1, nil, map2, nil, map1, nil, nil]
#    soapAry = SOAP::Mapping.ary2soap(arg, ApacheNS, "Map", SOAPBuildersInterop::MappingRegistry)
#    soapAry.sparse = true
#    var = drv.echoMapArray(soapAry)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoMapArray (multi-ref: elem1 == elem2)'
  dumpTitle(title)
  begin
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    arg = [map1, map1, map2]
    var = drv.echoMapArray(arg)
    dumpNormal(title, getIdObj(var[0]), getIdObj(var[1]))
  rescue Exception
    dumpException(title)
  end
end

end


###
## Invoke methods.
#
def doTestGroupB(drv)
  setWireDumpLogFile('_GroupB')
  drv.wiredump_dev = $wireDumpDev
#  drv.wiredump_filebase = getWireDumpLogFileBase('_GroupB')

  drv.mapping_registry = SOAPBuildersInterop::MappingRegistry

  title = 'echoStructAsSimpleTypes'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(1, 1.1, "a")
    ret, out1, out2 = drv.echoStructAsSimpleTypes(arg)
    var = SOAPStruct.new(out1, out2, ret)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoStructAsSimpleTypes (nil)'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(nil, nil, nil)
    ret, out1, out2 = drv.echoStructAsSimpleTypes(arg)
    var = SOAPStruct.new(out1, out2, ret)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoSimpleTypesAsStruct'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(1, 1.1, "a")
    var = drv.echoSimpleTypesAsStruct(arg.varString, arg.varInt, arg.varFloat)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoSimpleTypesAsStruct (nil)'
  dumpTitle(title)
  begin
    arg = SOAPStruct.new(nil, nil, nil)
    var = drv.echoSimpleTypesAsStruct(arg.varString, arg.varInt, arg.varFloat)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echo2DStringArray'
  dumpTitle(title)
  begin

#    arg = SOAP::SOAPArray.new(SOAP::ValueArrayName, 2, XSD::XSDString::Type)
#    arg[0, 0] = obj2soap('r0c0')
#    arg[1, 0] = obj2soap('r1c0')
#    arg[2, 0] = obj2soap('r2c0')
#    arg[0, 1] = obj2soap('r0c1')
#    arg[1, 1] = obj2soap('r1c1')
#    arg[2, 1] = obj2soap('r2c1')
#    arg[0, 2] = obj2soap('r0c2')
#    arg[1, 2] = obj2soap('r1c2')
#    arg[2, 2] = obj2soap('r2c2')

    arg = SOAP::SOAPArray.new(XSD::QName.new('http://soapinterop.org/xsd', 'ArrayOfString2D'), 2, XSD::XSDString::Type)
    arg.size = [3, 3]
    arg.size_fixed = true
    arg.add(SOAP::Mapping.obj2soap('r0c0', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r1c0', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r2c0', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r0c1', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r1c1', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r2c1', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r0c2', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r1c2', SOAPBuildersInterop::MappingRegistry))
    arg.add(SOAP::Mapping.obj2soap('r2c2', SOAPBuildersInterop::MappingRegistry))
    argNormalized = [
      ['r0c0', 'r1c0', 'r2c0'],
      ['r0c1', 'r1c1', 'r2c1'],
      ['r0c2', 'r1c2', 'r2c2'],
    ]

    var = drv.echo2DStringArray(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echo2DStringArray (anyType array)'
  dumpTitle(title)
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      ['r0c0', 'r0c1', 'r0c2'],
      ['r1c0', 'r1c1', 'r1c2'],
      ['r2c0', 'r0c1', 'r2c2'],
    ]

    paramArg = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry)
    paramArg.type = XSD::QName.new('http://soapinterop.org/xsd', 'ArrayOfString2D')
    var = drv.echo2DStringArray(paramArg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

#  title = 'echo2DStringArray (sparse)'
#  dumpTitle(title)
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    arg = [
#      ['r0c0', nil,    'r0c2'],
#      [nil,    'r1c1', 'r1c2'],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    md.sparse = true
#
#    var = drv.echo2DStringArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

#  title = 'echo2DStringArray (anyType, sparse)'
#  dumpTitle(title)
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    arg = [
#      ['r0c0', nil,    'r0c2'],
#      [nil,    'r1c1', 'r1c2'],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    md.sparse = true
#
#    var = drv.echo2DStringArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echo2DStringArray (multi-ref)'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPArray.new(XSD::QName.new('http://soapinterop.org/xsd', 'ArrayOfString2D'), 2, XSD::XSDString::Type)
    arg.size = [3, 3]
    arg.size_fixed = true

    item = 'item'
    arg.add('r0c0')
    arg.add('r1c0')
    arg.add(item)
    arg.add('r0c1')
    arg.add('r1c1')
    arg.add('r2c1')
    arg.add(item)
    arg.add('r1c2')
    arg.add('r2c2')
    argNormalized = [
      ['r0c0', 'r1c0', 'item'],
      ['r0c1', 'r1c1', 'r2c1'],
      ['item', 'r1c2', 'r2c2'],
    ]

    var = drv.echo2DStringArray(arg)
    dumpNormal(title, argNormalized, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echo2DStringArray (multi-ref: ele[2, 0] == ele[0, 2])'
  dumpTitle(title)
  begin
    arg = SOAP::SOAPArray.new(XSD::QName.new('http://soapinterop.org/xsd', 'ArrayOfString2D'), 2, XSD::XSDString::Type)
    arg.size = [3, 3]
    arg.size_fixed = true

    item = 'item'
    arg.add('r0c0')
    arg.add('r1c0')
    arg.add(item)
    arg.add('r0c1')
    arg.add('r1c1')
    arg.add('r2c1')
    arg.add(item)
    arg.add('r1c2')
    arg.add('r2c2')

    var = drv.echo2DStringArray(arg)
    dumpNormal(title, getIdObj(var[2][0]), getIdObj(var[0][2]))
  rescue Exception
    dumpException(title)
  end

#  title = 'echo2DStringArray (sparse, multi-ref)'
#  dumpTitle(title)
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    str = "BANG!"
#    arg = [
#      ['r0c0', nil, str   ],
#      [nil,    str, 'r1c2'],
#    ]
#    md = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    md.sparse = true
#
#    var = drv.echo2DStringArray(md)
#    dumpNormal(title, arg, var)
#  rescue Exception
#    dumpException(title)
#  end

  title = 'echoNestedStruct'
  dumpTitle(title)
  begin
    arg = SOAPStructStruct.new(1, 1.1, "a",
      SOAPStruct.new(2, 2.2, "b")
   )
    var = drv.echoNestedStruct(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedStruct (nil)'
  dumpTitle(title)
  begin
    arg = SOAPStructStruct.new(nil, nil, nil,
      SOAPStruct.new(nil, nil, nil)
   )
    var = drv.echoNestedStruct(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedStruct (multi-ref: varString of StructStruct == varString of Struct)'
  dumpTitle(title)
  begin
    str1 = ""
    arg = SOAPStructStruct.new(1, 1.1, str1,
      SOAPStruct.new(2, 2.2, str1)
   )
    var = drv.echoNestedStruct(arg)
    dumpNormal(title, getIdObj(var.varString), getIdObj(var.varStruct.varString))
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedArray'
  dumpTitle(title)
  begin
    arg = SOAPArrayStruct.new(1, 1.1, "a", StringArray["2", "2.2", "b"])
    var = drv.echoNestedArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedArray (anyType array)'
  dumpTitle(title)
  begin
    arg = SOAPArrayStruct.new(1, 1.1, "a", ["2", "2.2", "b"])
    var = drv.echoNestedArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedArray (multi-ref)'
  dumpTitle(title)
  begin
    str = ""
    arg = SOAPArrayStruct.new(1, 1.1, str, StringArray["2", str, "b"])
    var = drv.echoNestedArray(arg)
    dumpNormal(title, arg, var)
  rescue Exception
    dumpException(title)
  end

  title = 'echoNestedArray (multi-ref: varString == varArray[1])'
  dumpTitle(title)
  begin
    str = ""
    arg = SOAPArrayStruct.new(1, 1.1, str, StringArray["2", str, "b"])
    var = drv.echoNestedArray(arg)
    dumpNormal(title, getIdObj(var.varString), getIdObj(var.varArray[1]))
  rescue Exception
    dumpException(title)
  end

#  title = 'echoNestedArray (sparse, multi-ref)'
#  dumpTitle(title)
#  begin
#    str = "!"
#    subAry = [nil, nil, str, nil, str, nil]
#    ary = SOAP::Mapping.ary2soap(subAry, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry)
#    ary.sparse = true
#    arg = SOAPArrayStruct.new(1, 1.1, str, ary)
#    argNormalized = SOAPArrayStruct.new(1, 1.1, str, subAry)
#    var = drv.echoNestedArray(arg)
#    dumpNormal(title, argNormalized, var)
#  rescue Exception
#    dumpException(title)
#  end

end
