$KCODE = 'EUC'

require 'test/unit'
require 'soap/rpc/driver'
require 'soap/mapping'
require 'base'
require 'interopResultBase'
require 'xsd/xmlparser/rexmlparser'
#XSD::Charset.encoding = 'EUC'

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

class SOAPBuildersTest < Test::Unit::TestCase
  include SOAP
  include SOAPBuildersInterop

  NegativeZero = (-1.0 / (1.0 / 0.0))

  class << self
    include SOAP
    def setup(name, location)
      setup_log(name)
      setup_drv(location)
    end

    def teardown
    end

  private

    def setup_log(name)
      filename = File.basename($0).sub(/\.rb$/, '') << '.log'
      @@log = File.open(filename, 'w')
      @@log << "File: #{ filename } - Wiredumps for SOAP4R client / #{ name } server.\n"
      @@log << "Date: #{ Time.now }\n\n"
    end

    def setup_drv(location)
      namespace = InterfaceNS
      soap_action = InterfaceNS
      @@drv = RPC::Driver.new(location, namespace, soap_action)
      @@drv.mapping_registry = SOAPBuildersInterop::MappingRegistry
      if $DEBUG
        @@drv.wiredump_dev = STDOUT
      else
        @@drv.wiredump_dev = @@log
      end
      method_def(@@drv, soap_action)
    end

    def method_def(drv, soap_action = nil)
      do_method_def(drv, SOAPBuildersInterop::MethodsBase, soap_action)
      do_method_def(drv, SOAPBuildersInterop::MethodsGroupB, soap_action)
    end

    def do_method_def(drv, defs, soap_action = nil)
      defs.each do |name, *params|
        drv.add_rpc_operation(
          XSD::QName.new(InterfaceNS, name), soap_action, name, params)
      end
    end
  end

  def setup
  end

  def teardown
  end

  def drv
    @@drv
  end

  def log_test
    /`([^']+)'/ =~ caller(1)[0]
    title = $1
    title = "==== " + title + " " << "=" * (title.length > 72 ? 0 : (72 - title.length))
    @@log << "#{title}\n\n"
  end

  def assert_exception(klass_or_module)
    begin
      yield
      assert(false, "Exception was not raised.")
    rescue Exception => e
      if klass_or_module.is_a?(Module)
	assert_kind_of(klass_or_module, e)
      elsif klass_or_module.is_a?(Class)
	assert_instance_of(klass_or_module, e)
      else
	assert(false, "Must be a klass or a mogule.")
      end
    end
  end

  def inspect_with_id(obj)
    case obj
    when Array
      obj.collect { |ele| inspect_with_id(ele) }
    else
      # String#== compares content of args.
      "#{ obj.class }##{ obj.__id__ }"
    end
  end

  def dump_result(title, result, resultStr)
    @@test_result.add(
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

  def test_echoVoid
    log_test
    var =  drv.echoVoid()
    assert_equal(nil, var)
  end

  def test_echoString
    log_test
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_Entity_reference
    log_test
    arg = "<>\"& &lt;&gt;&quot;&amp; &amp&amp;><<<"
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_haracter_reference
    log_test
    arg = "\x20&#x20;\040&#32;\x7f&#x7f;\177&#127;"
    tobe = "    \177\177\177\177"
    var = drv.echoString(SOAP::SOAPRawString.new(arg))
    assert_equal(tobe, var)
  end

  def test_echoString_Leading_and_trailing_whitespace
    log_test
    arg = "   SOAP4R\nInteroperability\nTest   "
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_EUC_encoded
    log_test
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_EUC_encoded_again
    log_test
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_SJIS_encoded
    log_test
    arg = "Hello (日本語Japanese) こんにちは"
    require 'nkf'
    arg = NKF.nkf("-sm0", arg)
    drv.options["soap.mapping.external_ces"] = 'SJIS'
    begin
      var = drv.echoString(arg)
      assert_equal(arg, var)
    ensure
      drv.options["soap.mapping.external_ces"] = nil
    end
  end

  def test_echoString_empty
    log_test
    arg = ''
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_space
    log_test
    arg = ' '
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoString_whitespaces
    log_test
    arg = "\r \n \t \r \n \t"
    var = drv.echoString(arg)
    assert_equal(arg, var)
  end

  def test_echoStringArray
    log_test
    arg = StringArray["SOAP4R\n", " Interoperability ", "\tTest\t"]
    var = drv.echoStringArray(arg)
    assert_equal(arg, var)
  end

  def test_echoStringArray_multi_ref
    log_test
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    assert_equal(arg, var)
  end

  def test_echoStringArray_multi_ref_idmatch
    log_test
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    assert_equal(inspect_with_id(var[0]), inspect_with_id(var[2]))
  end

  def test_echoStringArray_empty_multi_ref_idmatch
    log_test
    str1 = ""
    str2 = ""
    arg = StringArray[str1, str2, str1]
    var = drv.echoStringArray(arg)
    assert_equal(inspect_with_id(var[0]), inspect_with_id(var[2]))
  end

  def test_echoInteger_123
    log_test
    arg = 123
    var = drv.echoInteger(arg)
    assert_equal(arg, var)
  end

  def test_echoInteger_2147483647
    log_test
    arg = 2147483647
    var = drv.echoInteger(arg)
    assert_equal(arg, var)
  end

  def test_echoInteger_negative_2147483648
    log_test
    arg = -2147483648
    var = drv.echoInteger(arg)
    assert_equal(arg, var)
  end

  def test_echoInteger_2147483648_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("2147483648")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoInteger_negative_2147483649_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("-2147483649")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoInteger_0_0_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("0.0")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoInteger_negative_5_2_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("-5.2")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoInteger_0_000000000a_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("0.000000000a")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoInteger_plus_minus_5_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeInt.new("+-5")
      var = drv.echoInteger(arg)
    end
  end

  def test_echoIntegerArray
    log_test
    arg = IntArray[1, 2, 3]
    var = drv.echoIntegerArray(arg)
    assert_equal(arg, var)
  end

  def test_echoIntegerArray_empty
    log_test
    arg = SOAP::SOAPArray.new(SOAP::ValueArrayName, 1, XSD::XSDInt::Type)
    var = drv.echoIntegerArray(arg)
    assert_equal([], var)
  end

  def test_echoFloat
    log_test
    arg = 3.14159265358979
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_scientific_notation
    log_test
    arg = 12.34e36
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_scientific_notation_2
    log_test
    arg = FakeFloat.new("12.34e36")
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(12.34e36, var)
  end

  def test_echoFloat_scientific_notation_3
    log_test
    arg = FakeFloat.new("12.34E+36")
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(12.34e36, var)
  end

  def test_echoFloat_scientific_notation_4
    log_test
    arg = FakeFloat.new("-1.4E")
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(1.4, var)
  end

  def test_echoFloat_positive_lower_boundary
    log_test
    arg = 1.4e-45
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_negative_lower_boundary
    log_test
    arg = -1.4e-45
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_special_values_positive_0
    log_test
    arg = 0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_special_values_negative_0
    log_test
    arg = NegativeZero
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_special_values_NaN
    log_test
    arg = 0.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_special_values_positive_INF
    log_test
    arg = 1.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_special_values_negative_INF
    log_test
    arg = -1.0/0.0
    var = drv.echoFloat(SOAPFloat.new(arg))
    assert_equal(arg, var)
  end

  def test_echoFloat_0_000a_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeFloat.new("0.0000000000000000a")
      var = drv.echoFloat(arg)
    end
  end

  def test_echoFloat_00a_0001_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeFloat.new("00a.000000000000001")
      var = drv.echoFloat(arg)
    end
  end

  def test_echoFloat_plus_minus_5_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeFloat.new("+-5")
      var = drv.echoFloat(arg)
    end
  end

  def test_echoFloat_5_0_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeFloat.new("5_0")
      var = drv.echoFloat(arg)
    end
  end

  def test_echoFloatArray
    log_test
    arg = FloatArray[SOAPFloat.new(0.0001), SOAPFloat.new(1000.0),
      SOAPFloat.new(0.0)]
    var = drv.echoFloatArray(arg)
    assert_equal(arg.collect { |ele| ele.data }, var)
  end

  def test_echoFloatArray_special_values_NaN_positive_INF_negative_INF
    log_test
    nan = SOAPFloat.new(0.0/0.0)
    inf = SOAPFloat.new(1.0/0.0)
    inf_ = SOAPFloat.new(-1.0/0.0)
    arg = FloatArray[nan, inf, inf_]
    var = drv.echoFloatArray(arg)
    assert_equal(arg.collect { |ele| ele.data }, var)
  end

  def test_echoStruct
    log_test
    arg = SOAPStruct.new(1, 1.1, "a")
    var = drv.echoStruct(arg)
    assert_equal(arg, var)
  end

  def test_echoStruct_nil_members
    log_test
    arg = SOAPStruct.new(nil, nil, nil)
    var = drv.echoStruct(arg)
    assert_equal(arg, var)
  end

  def test_echoStructArray
    log_test
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    s3 = SOAPStruct.new(3, 3.3, "c")
    arg = SOAPStructArray[s1, s2, s3]
    var = drv.echoStructArray(arg)
    assert_equal(arg, var)
  end

  def test_echoStructArray_anyType_Array
    log_test
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    s3 = SOAPStruct.new(3, 3.3, "c")
    arg = [s1, s2, s3]
    var = drv.echoStructArray(arg)
    assert_equal(arg, var)
  end

  def test_echoStructArray_multi_ref
    log_test
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = SOAPStructArray[s1, s1, s2]
    var = drv.echoStructArray(arg)
    assert_equal(arg, var)
  end

  def test_echoStructArray_multi_ref_idmatch
    log_test
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = SOAPStructArray[s1, s1, s2]
    var = drv.echoStructArray(arg)
    assert_equal(inspect_with_id(var[0]), inspect_with_id(var[1]))
  end

  def test_echoStructArray_anyType_Array_multi_ref_idmatch
    log_test
    s1 = SOAPStruct.new(1, 1.1, "a")
    s2 = SOAPStruct.new(2, 2.2, "b")
    arg = [s1, s2, s2]
    var = drv.echoStructArray(arg)
    assert_equal(inspect_with_id(var[1]), inspect_with_id(var[2]))
  end

  def test_echoStructArray_multi_ref_idmatch_varString_of_elem1_varString_of_elem2
    log_test
    str1 = "a"
    str2 = "a"
    s1 = SOAPStruct.new(1, 1.1, str1)
    s2 = SOAPStruct.new(2, 2.2, str1)
    s3 = SOAPStruct.new(3, 3.3, str2)
    arg = SOAPStructArray[s1, s2, s3]
    var = drv.echoStructArray(arg)
    assert_equal(inspect_with_id(var[0].varString), inspect_with_id(var[1].varString))
  end

  def test_echoStructArray_anyType_Array_multi_ref_idmatch_varString_of_elem2_varString_of_elem3
    log_test
    str1 = "b"
    str2 = "b"
    s1 = SOAPStruct.new(1, 1.1, str2)
    s2 = SOAPStruct.new(2, 2.2, str1)
    s3 = SOAPStruct.new(3, 3.3, str1)
    arg = [s1, s2, s3]
    var = drv.echoStructArray(arg)
    assert_equal(inspect_with_id(var[1].varString), inspect_with_id(var[2].varString))
  end

  def test_echoDate_now
    log_test
    t = Time.now.gmtime
    arg = DateTime.new(t.year, t.mon, t.mday, t.hour, t.min, t.sec)
    var = drv.echoDate(arg)
    assert_equal(arg.to_s, var.to_s)
  end

  def test_echoDate_before_1970
    log_test
    t = Time.now.gmtime
    arg = DateTime.new(1, 1, 1, 0, 0, 0)
    var = drv.echoDate(arg)
    assert_equal(arg.to_s, var.to_s)
  end

  def test_echoDate_after_2038
    log_test
    t = Time.now.gmtime
    arg = DateTime.new(2038, 12, 31, 0, 0, 0)
    var = drv.echoDate(arg)
    assert_equal(arg.to_s, var.to_s)
  end

  def test_echoDate_negative_10_01_01T00_00_00Z
    log_test
    t = Time.now.gmtime
    arg = DateTime.new(-10, 1, 1, 0, 0, 0)
    var = drv.echoDate(arg)
    assert_equal(arg.to_s, var.to_s)
  end

  def test_echoDate_time_precision_msec
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40.012')
    argDate = arg.data
    var = drv.echoDate(arg)
    assert_equal(argDate, var)
  end

  def test_echoDate_time_precision_long
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40.0000000000123456789012345678900000000000')
    argDate = arg.data
    var = drv.echoDate(arg)
    assert_equal(argDate, var)
  end

  def test_echoDate_positive_TZ
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40+07:00')
    argNormalized = DateTime.new(2001, 6, 16, 18, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_negative_TZ
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_positive_00_00_TZ
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40+00:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_negative_00_00_TZ
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-17T01:13:40-00:00')
    argNormalized = DateTime.new(2001, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_min_TZ
    log_test
    arg = SOAP::SOAPDateTime.new('2001-06-16T00:00:01+00:01')
    argNormalized = DateTime.new(2001, 6, 15, 23, 59, 1)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_year_9999
    log_test
    arg = SOAP::SOAPDateTime.new('10000-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(10000, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_year_0
    log_test
    arg = SOAP::SOAPDateTime.new('-0001-06-16T18:13:40-07:00')
    argNormalized = DateTime.new(0, 6, 17, 1, 13, 40)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_year_4713
    log_test
    arg = SOAP::SOAPDateTime.new('-4713-01-01T12:00:00')
    argNormalized = DateTime.new(-4712, 1, 1, 12, 0, 0)
    var = drv.echoDate(arg)
    assert_equal(argNormalized, var)
  end

  def test_echoDate_year_0000_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDateTime.new("0000-05-18T16:52:20Z")
      var = drv.echoDate(arg)
    end
  end

  def test_echoDate_year_nn_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDateTime.new("05-05-18T16:52:20Z")
      var = drv.echoDate(arg)
    end
  end

  def test_echoDate_no_day_part_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDateTime.new("2002-05T16:52:20Z")
      var = drv.echoDate(arg)
    end
  end

  def test_echoDate_no_sec_part_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDateTime.new("2002-05-18T16:52Z")
      var = drv.echoDate(arg)
    end
  end

  def test_echoDate_empty_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDateTime.new("")
      var = drv.echoDate(arg)
    end
  end

  def test_echoBase64_xsd_base64Binary
    log_test
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new(str)
    arg.as_xsd	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64(arg)
    assert_equal(str, var)
  end

  def test_echoBase64_xsd_base64Binary_empty
    log_test
    str = ""
    arg = SOAP::SOAPBase64.new(str)
    arg.as_xsd	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64(arg)
    assert_equal(str, var)
  end

  def test_echoBase64_SOAP_ENC_base64
    log_test
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    assert_equal(str, var)
  end

  def test_echoBase64_0
    log_test
    str = "\0"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    assert_equal(str, var)
  end

  def test_echoBase64_0a_0
    log_test
    str = "a\0b\0\0c\0\0\0"
    arg = SOAP::SOAPBase64.new(str)
    var = drv.echoBase64(arg)
    assert_equal(str, var)
  end

  def test_echoBase64_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = SOAP::SOAPBase64.new("dummy")
      arg.instance_eval { @data = '-' }
      var = drv.echoBase64(arg)
    end
  end

  def test_echoHexBinary
    log_test
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    assert_equal(str, var)
  end

  def test_echoHexBinary_empty
    log_test
    str = ""
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    assert_equal(str, var)
  end

  def test_echoHexBinary_0
    log_test
    str = "\0"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    assert_equal(str, var)
  end

  def test_echoHexBinary_0a_0
    log_test
    str = "a\0b\0\0c\0\0\0"
    arg = SOAP::SOAPHexBinary.new(str)
    var = drv.echoHexBinary(arg)
    assert_equal(str, var)
  end

  def test_echoHexBinary_lower_case
    log_test
    str = "lower case"
    arg = SOAP::SOAPHexBinary.new
    arg.set_encoded((str.unpack("H*")[0]).tr('A-F', 'a-f'))
    var = drv.echoHexBinary(arg)
    assert_equal(str, var)
  end

  def test_echoHexBinary_0FG7_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = SOAP::SOAPHexBinary.new("dummy")
      arg.instance_eval { @data = '0FG7' }
      var = drv.echoHexBinary(arg)
    end
  end

  def test_echoBoolean_true
    log_test
    arg = true
    var = drv.echoBoolean(arg)
    assert_equal(arg, var)
  end

  def test_echoBoolean_false
    log_test
    arg = false
    var = drv.echoBoolean(arg)
    assert_equal(arg, var)
  end

  def test_echoBoolean_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = SOAP::SOAPBoolean.new(true)
      arg.instance_eval { @data = 'junk' }
      var = drv.echoBoolean(arg)
    end
  end

  def test_echoDecimal_123456
    log_test
    arg = "123456789012345678"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = arg
    assert_equal(normalized, var)
  end

  def test_echoDecimal_0_123
    log_test
    arg = "+0.12345678901234567"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = arg.sub(/0$/, '').sub(/^\+/, '')
    assert_equal(normalized, var)
  end

  def test_echoDecimal_00000123
    log_test
    arg = ".00000123456789012"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = '0' << arg.sub(/0$/, '')
    assert_equal(normalized, var)
  end

  def test_echoDecimal_negative_00000123
    log_test
    arg = "-.00000123456789012"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    normalized = '-0' << arg.sub(/0$/, '').sub(/-/, '')
    assert_equal(normalized, var)
  end

  def test_echoDecimal_123_456
    log_test
    arg = "-123456789012345.008"
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    assert_equal(arg, var)
  end

  def test_echoDecimal_123
    log_test
    arg = "-12345678901234567."
    normalized = arg.sub(/\.$/, '')
    var = drv.echoDecimal(SOAP::SOAPDecimal.new(arg))
    assert_equal(normalized, var)
  end

  def test_echoDecimal_0_000a_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDecimal.new("0.0000000000000000a")
      var = drv.echoDecimal(arg)
    end
  end

  def test_echoDecimal_00a_0001_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDecimal.new("00a.000000000000001")
      var = drv.echoDecimal(arg)
    end
  end

  def test_echoDecimal_plus_minus_5_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDecimal.new("+-5")
      var = drv.echoDecimal(arg)
    end
  end

  def test_echoDecimal_5_0_junk
    log_test
    assert_exception(SOAP::RPC::ServerException) do
      arg = FakeDecimal.new("5_0")
      var = drv.echoDecimal(arg)
    end
  end

  def test_echoMap
    log_test
    arg = { "a" => 1, "b" => 2 }
    var = drv.echoMap(arg)
    assert_equal(arg, var)
  end

  def test_echoMap_boolean_base64_nil_float
    log_test
    arg = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    var = drv.echoMap(arg)
    assert_equal(arg, var)
  end

  def test_echoMap_multibyte_char
    log_test
    arg = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    var = drv.echoMap(arg)
    assert_equal(arg, var)
  end

  def test_echoMap_Struct
    log_test
    obj = SOAPStruct.new(1, 1.1, "a")
    arg = { 1 => obj, 2 => obj }
    var = drv.echoMap(arg)
    assert_equal(arg, var)
  end

  def test_echoMap_multi_ref_idmatch_value_for_key_a
    log_test
    value = "c"
    arg = { "a" => value, "b" => value }
    var = drv.echoMap(arg)
    assert_equal(inspect_with_id(var["a"]), inspect_with_id(var["b"]))
  end

  def test_echoMap_Struct_multi_ref_idmatch_varString_of_a_key
    log_test
    str = ""
    obj = SOAPStruct.new(1, 1.1, str)
    arg = { obj => "1", "1" => obj }
    var = drv.echoMap(arg)
    assert_equal(inspect_with_id(var.index("1").varString), inspect_with_id(var.fetch("1").varString))
  end

  def test_echoMapArray
    log_test
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    map3 = { "a" => 1, "b" => 2 }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    assert_equal(arg, var)
  end

  def test_echoMapArray_boolean_base64_nil_float
    log_test
    map1 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map2 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map3 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    assert_equal(arg, var)
  end

  def test_echoMapArray_multibyte_char
    log_test
    map1 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map2 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map3 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    arg = [map1, map2, map3]
    var = drv.echoMapArray(arg)
    assert_equal(arg, var)
  end

  def test_echoMapArray_multi_ref_idmatch
    log_test
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    arg = [map1, map1, map2]
    var = drv.echoMapArray(arg)
    assert_equal(inspect_with_id(var[0]), inspect_with_id(var[1]))
  end

  def test_echoStructAsSimpleTypes
    log_test
    arg = SOAPStruct.new(1, 1.1, "a")
    ret, out1, out2 = drv.echoStructAsSimpleTypes(arg)
    var = SOAPStruct.new(out1, out2, ret)
    assert_equal(arg, var)
  end

  def test_echoStructAsSimpleTypes_nil
    log_test
    arg = SOAPStruct.new(nil, nil, nil)
    ret, out1, out2 = drv.echoStructAsSimpleTypes(arg)
    var = SOAPStruct.new(out1, out2, ret)
    assert_equal(arg, var)
  end

  def test_echoSimpleTypesAsStruct
    log_test
    arg = SOAPStruct.new(1, 1.1, "a")
    var = drv.echoSimpleTypesAsStruct(arg.varString, arg.varInt, arg.varFloat)
    assert_equal(arg, var)
  end

  def test_echoSimpleTypesAsStruct_nil
    log_test
    arg = SOAPStruct.new(nil, nil, nil)
    var = drv.echoSimpleTypesAsStruct(arg.varString, arg.varInt, arg.varFloat)
    assert_equal(arg, var)
  end

  def test_echo2DStringArray
    log_test
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
    assert_equal(argNormalized, var)
  end

  def test_echo2DStringArray_anyType_array
    log_test
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      ['r0c0', 'r0c1', 'r0c2'],
      ['r1c0', 'r1c1', 'r1c2'],
      ['r2c0', 'r0c1', 'r2c2'],
   ]

    paramArg = SOAP::Mapping.ary2md(arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry)
    paramArg.type = XSD::QName.new('http://soapinterop.org/xsd', 'ArrayOfString2D')
    var = drv.echo2DStringArray(paramArg)
    assert_equal(arg, var)
  end

  def test_echo2DStringArray_multi_ref
    log_test
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
    assert_equal(argNormalized, var)
  end

  def test_echo2DStringArray_multi_ref_idmatch
    log_test
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
    assert_equal(inspect_with_id(var[2][0]), inspect_with_id(var[0][2]))
  end

  def test_echoNestedStruct
    log_test
    arg = SOAPStructStruct.new(1, 1.1, "a",
      SOAPStruct.new(2, 2.2, "b")
  )
    var = drv.echoNestedStruct(arg)
    assert_equal(arg, var)
  end

  def test_echoNestedStruct_nil
    log_test
    arg = SOAPStructStruct.new(nil, nil, nil,
      SOAPStruct.new(nil, nil, nil)
  )
    var = drv.echoNestedStruct(arg)
    assert_equal(arg, var)
  end

  def test_echoNestedStruct_multi_ref_idmatch
    log_test
    str1 = ""
    arg = SOAPStructStruct.new(1, 1.1, str1,
      SOAPStruct.new(2, 2.2, str1)
  )
    var = drv.echoNestedStruct(arg)
    assert_equal(inspect_with_id(var.varString), inspect_with_id(var.varStruct.varString))
  end

  def test_echoNestedArray
    log_test
    arg = SOAPArrayStruct.new(1, 1.1, "a", StringArray["2", "2.2", "b"])
    var = drv.echoNestedArray(arg)
    assert_equal(arg, var)
  end

  def test_echoNestedArray_anyType_array
    log_test
    arg = SOAPArrayStruct.new(1, 1.1, "a", ["2", "2.2", "b"])
    var = drv.echoNestedArray(arg)
    assert_equal(arg, var)
  end

  def test_echoNestedArray_multi_ref
    log_test
    str = ""
    arg = SOAPArrayStruct.new(1, 1.1, str, StringArray["2", str, "b"])
    var = drv.echoNestedArray(arg)
    assert_equal(arg, var)
  end

  def test_echoNestedArray_multi_ref_idmatch
    log_test
    str = ""
    arg = SOAPArrayStruct.new(1, 1.1, str, StringArray["2", str, "b"])
    var = drv.echoNestedArray(arg)
    assert_equal(inspect_with_id(var.varString), inspect_with_id(var.varArray[1]))
  end
end

if $0 == __FILE__
  #name = ARGV.shift || 'localhost'
  #location = ARGV.shift || 'http://localhost:10080/'
  name = 'localhsot'; location = 'http://localhost:10080/'
  SOAPBuildersTest.setup(name, location)
end
