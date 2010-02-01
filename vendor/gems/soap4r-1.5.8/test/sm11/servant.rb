require 'classDef'

# Done
#   System.out.print -> STDOUT.puts
#   a1 -> arg0
#   a2 -> arg1
#   a3 -> arg2
#   a4 -> arg3
#   a5 -> arg4
#   /if \([^{]*\){\([^}]*\)}/if \1; \2; end/
#   /\([0-9][0-9]*\)L/\1/
#   /\([0-9][0-9]*\)f/\1/
#   /\.equals(\([^)]*\))/ == \1/
#   /\.set\([^(]*\)(\([^)]*\))/.\1 = \2/
#   /E_/e_/
#   /\.get\([^(]*\)()/.\1/
#   /(short)//
#   /\.V/.v/
#
class Sm11PortType
  include SOAP

  # SYNOPSIS
  #   op0
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op0
    STDOUT.puts("op0\n")
    return
  end

  # SYNOPSIS
  #   op1( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op1( arg0 )
    STDOUT.puts("op1\n")
    if (!(arg0 == false)); STDOUT.puts("arg0 value error in op1\n"); end
    return
  end

  # SYNOPSIS
  #   op4( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}short
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op4( arg0 )
    STDOUT.puts("op4\n")
    if (!(arg0 == -100)); STDOUT.puts("arg0 value error in op4\n"); end
    return
  end

  # SYNOPSIS
  #   op5( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}int
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op5( arg0 )
    STDOUT.puts("op5\n")
    if (!(arg0 == -100000)); STDOUT.puts("arg0 value error in op5\n"); end
    return
  end

  # SYNOPSIS
  #   op6( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}long
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op6( arg0 )
    STDOUT.puts("op6\n")
    if (!(arg0 == -10000000000)); STDOUT.puts("arg0 value error in op6\n"); end
    return
  end

  # SYNOPSIS
  #   op7( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}float
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op7( arg0 )
    STDOUT.puts("op7\n")
    if (!(arg0 == 0.123)); STDOUT.puts("arg0 value error in op7\n"); end
    return
  end

  # SYNOPSIS
  #   op8( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}double
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op8( arg0 )
    STDOUT.puts("op8\n")
    if (!(arg0 == 0.12e3)); STDOUT.puts("arg0 value error in op8\n"); end
    return
  end

  # SYNOPSIS
  #   op9( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op9( arg0 )
    STDOUT.puts("op9\n")
    if (!(arg0 == "abc")); STDOUT.puts("arg0 value error in op9\n"); end
    return
  end

  # SYNOPSIS
  #   op11
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RAISES
  #    N/A
  #
  def op11
    STDOUT.puts("op11\n")
    _ret = true
    return(_ret)
  end

  # SYNOPSIS
  #   op14
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}short
  #
  # RAISES
  #    N/A
  #
  def op14
    STDOUT.puts("op14\n")
    _ret = SOAPShort.new(-200)
    return(_ret)
  end

  # SYNOPSIS
  #   op15
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}int
  #
  # RAISES
  #    N/A
  #
  def op15
    STDOUT.puts("op15\n")
    _ret = SOAPInt.new( -200000 )
    return(_ret)
  end

  # SYNOPSIS
  #   op16
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}long
  #
  # RAISES
  #    N/A
  #
  def op16
    STDOUT.puts("op16\n")
    _ret = SOAPLong.new( -20000000000 )
    return(_ret)
  end

  # SYNOPSIS
  #   op17
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}float
  #
  # RAISES
  #    N/A
  #
  def op17
    STDOUT.puts("op17\n")
    _ret = SOAPFloat.new(1.234)
    return(_ret)
  end

  # SYNOPSIS
  #   op18
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}double
  #
  # RAISES
  #    N/A
  #
  def op18
    STDOUT.puts("op18\n")
    _ret = 1.23e4
    return(_ret)
  end

  # SYNOPSIS
  #   op19
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}string
  #
  # RAISES
  #    N/A
  #
  def op19
    STDOUT.puts("op19\n")
    _ret = "def"
    return(_ret)
  end

  # SYNOPSIS
  #   op21( arg0 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RAISES
  #    N/A
  #
  def op21( arg0 )
    STDOUT.puts("op21\n")
    if (!(arg0 == false)); STDOUT.puts("arg0 value error in op21\n"); end
    _ret = true
    return(_ret)
  end

  # SYNOPSIS
  #   op24( arg0, arg1, arg2 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}short
  #   arg1		{http://www.w3.org/2001/XMLSchema}int
  #   arg2		{http://www.w3.org/2001/XMLSchema}long
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}short
  #
  # RAISES
  #    N/A
  #
  def op24( arg0, arg1, arg2 )
    STDOUT.puts("op24\n")
    if (!(arg0 == -100)); STDOUT.puts("arg0 value error in op24\n"); end
    if (!(arg1 == -100000)); STDOUT.puts("arg1 value error in op24\n"); end
    if (!(arg2 == -10000000000)); STDOUT.puts("arg2 value error in op24\n"); end
    _ret = SOAPShort.new(-200)
    return(_ret)
  end

  # SYNOPSIS
  #   op25( arg0, arg1, arg2 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}int
  #   arg1		{http://www.w3.org/2001/XMLSchema}long
  #   arg2		{http://www.w3.org/2001/XMLSchema}float
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}int
  #
  # RAISES
  #    N/A
  #
  def op25( arg0, arg1, arg2 )
    STDOUT.puts("op25\n")
    if (!(arg0 == -100000)); STDOUT.puts("arg0 value error in op25\n"); end
    if (!(arg1 == -10000000000)); STDOUT.puts("arg1 value error in op25\n"); end
    if (!(arg2 == 0.123)); STDOUT.puts("arg2 value error in op25\n"); end
    _ret = SOAPInt.new( -200000 )
    return(_ret)
  end

  # SYNOPSIS
  #   op26( arg0, arg1, arg2 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}long
  #   arg1		{http://www.w3.org/2001/XMLSchema}float
  #   arg2		{http://www.w3.org/2001/XMLSchema}double
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}long
  #
  # RAISES
  #    N/A
  #
  def op26( arg0, arg1, arg2 )
    STDOUT.puts("op26\n")
    if (!(arg0 == -10000000000)); STDOUT.puts("arg0 value error in op26\n"); end
    if (!(arg1 == 0.123)); STDOUT.puts("arg1 value error in op26\n"); end
    if (!(arg2 == 0.12e3)); STDOUT.puts("arg2 value error in op26\n"); end
    _ret = SOAPLong.new( -20000000000 )
    return(_ret)
  end

  # SYNOPSIS
  #   op27( arg0, arg1, arg2 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}float
  #   arg1		{http://www.w3.org/2001/XMLSchema}double
  #   arg2		{http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}float
  #
  # RAISES
  #    N/A
  #
  def op27( arg0, arg1, arg2 )
    STDOUT.puts("op27\n")
    if (!(arg0 == 0.123)); STDOUT.puts("arg0 value error in op27\n"); end
    if (!(arg1 == 0.12e3)); STDOUT.puts("arg1 value error in op27\n"); end
    if (!(arg2 == "abc")); STDOUT.puts("arg2 value error in op27\n"); end
    _ret = SOAPFloat.new(1.234)
    return(_ret)
  end

  # SYNOPSIS
  #   op28( arg0, arg1, arg2 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}double
  #   arg1		{http://www.w3.org/2001/XMLSchema}string
  #   arg2		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}double
  #
  # RAISES
  #    N/A
  #
  def op28( arg0, arg1, arg2 )
    STDOUT.puts("op28\n")
    if (!(arg0 == 0.12e3)); STDOUT.puts("arg0 value error in op28\n"); end
    if (!(arg1 == "abc")); STDOUT.puts("arg1 value error in op28\n"); end
    if (!(arg2 == false)); STDOUT.puts("arg2 value error in op28\n"); end
    _ret = 1.23e4
    return(_ret)
  end

  # SYNOPSIS
  #   op29( arg0, arg1 )
  #
  # ARGS
  #   arg0		{http://www.w3.org/2001/XMLSchema}string
  #   arg1		{http://www.w3.org/2001/XMLSchema}boolean
  #
  # RETURNS
  #   result		{http://www.w3.org/2001/XMLSchema}string
  #
  # RAISES
  #    N/A
  #
  def op29( arg0, arg1 )
    STDOUT.puts("op29\n")
    if (!(arg0 == "abc")); STDOUT.puts("arg0 value error in op29\n"); end
    if (!(arg1 == false)); STDOUT.puts("arg1 value error in op29\n"); end
    _ret = "def"
    return(_ret)
  end

  # SYNOPSIS
  #   op30( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}C_struct
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}C_struct
  #
  # RAISES
  #    N/A
  #
  def op30( arg0 )
    STDOUT.puts("op30\n")
    if (!comp_0012(arg0)); STDOUT.puts("arg0 value error in op30\n"); end
    _ret = cons_0007()
    return(_ret)
  end

  # SYNOPSIS
  #   op31( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfboolean
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfboolean
  #
  # RAISES
  #    N/A
  #
  def op31( arg0 )
    STDOUT.puts("op31\n")
    if (!(true && (arg0[0] == false) && (arg0[1] == false))); STDOUT.puts("arg0 value error in op31\n"); end
    _ret = ArrayOfboolean[true, true]
    return(_ret)
  end

  # SYNOPSIS
  #   op34( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfshort
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfshort
  #
  # RAISES
  #    N/A
  #
  def op34( arg0 )
    STDOUT.puts("op34\n")
    if (!(true && (arg0[0] == -100) && (arg0[1] == -100))); STDOUT.puts("arg0 value error in op34\n"); end
    _ret = ArrayOfshort[-200, -200]
    return(_ret)
  end

  # SYNOPSIS
  #   op35( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfint
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfint
  #
  # RAISES
  #    N/A
  #
  def op35( arg0 )
    STDOUT.puts("op35\n")
    if (!(true && (arg0[0] == -100000) && (arg0[1] == -100000))); STDOUT.puts("arg0 value error in op35\n"); end
    _ret = ArrayOfint[-200000, -200000]
    return(_ret)
  end

  # SYNOPSIS
  #   op36( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOflong
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOflong
  #
  # RAISES
  #    N/A
  #
  def op36( arg0 )
    STDOUT.puts("op36\n")
    if (!(true && (arg0[0] == -10000000000) && (arg0[1] == -10000000000))); STDOUT.puts("arg0 value error in op36\n"); end
    _ret = ArrayOflong[-20000000000, -20000000000]
    return(_ret)
  end

  # SYNOPSIS
  #   op37( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOffloat
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOffloat
  #
  # RAISES
  #    N/A
  #
  def op37( arg0 )
    STDOUT.puts("op37\n")
    if (!(true && (arg0[0] == 0.123) && (arg0[1] == 0.123))); STDOUT.puts("arg0 value error in op37\n"); end
    _ret = ArrayOffloat[1.234, 1.234]
    return(_ret)
  end

  # SYNOPSIS
  #   op38( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfdouble
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfdouble
  #
  # RAISES
  #    N/A
  #
  def op38( arg0 )
    STDOUT.puts("op38\n")
    if (!(true && (arg0[0] == 0.12e3) && (arg0[1] == 0.12e3))); STDOUT.puts("arg0 value error in op38\n"); end
    _ret = ArrayOfdouble[1.23e4, 1.23e4]
    return(_ret)
  end

  # SYNOPSIS
  #   op39( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfstring
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfstring
  #
  # RAISES
  #    N/A
  #
  def op39( arg0 )
    STDOUT.puts("op39\n")
    if (!(true && (arg0[0] == "abc") && (arg0[1] == "abc"))); STDOUT.puts("arg0 value error in op39\n"); end
    _ret = ArrayOfstring["def", "def"]
    return(_ret)
  end

  # SYNOPSIS
  #   op40( arg0, arg1, arg2, arg3, arg4 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}C_struct
  #   arg1		{http://dopg.gr.jp/sm11.xsd}ArrayOfboolean
  #   arg2		{http://dopg.gr.jp/sm11.xsd}ArrayOfint
  #   arg3		{http://dopg.gr.jp/sm11.xsd}ArrayOfdouble
  #   arg4		{http://dopg.gr.jp/sm11.xsd}ArrayOfstring
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op40( arg0, arg1, arg2, arg3, arg4 )
    STDOUT.puts("op40\n")
    if (!comp_0013(arg0)); STDOUT.puts("arg0 value error in op40\n"); end
    if (!(true && (arg1[0] == false) && (arg1[1] == false))); STDOUT.puts("arg1 value error in op40\n"); end
    if (!(true && (arg2[0] == -100000) && (arg2[1] == -100000))); STDOUT.puts("arg2 value error in op40\n"); end
    if (!(true && (arg3[0] == 0.12e3) && (arg3[1] == 0.12e3))); STDOUT.puts("arg3 value error in op40\n"); end
    if (!(true && (arg4[0] == "abc") && (arg4[1] == "abc"))); STDOUT.puts("arg4 value error in op40\n"); end
    return
  end

  # SYNOPSIS
  #   op41( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}F_struct
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}F_struct
  #
  # RAISES
  #    N/A
  #
  def op41( arg0 )
    STDOUT.puts("op41\n")
    if (!comp_0014(arg0)); STDOUT.puts("arg0 value error in op41\n"); end
    _ret = cons_0008()
    return(_ret)
  end

  # SYNOPSIS
  #   op42( arg0 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}ArrayOfC_struct
  #
  # RETURNS
  #   result		{http://dopg.gr.jp/sm11.xsd}ArrayOfC_struct
  #
  # RAISES
  #    N/A
  #
  def op42( arg0 )
    STDOUT.puts("op42\n")
    if (!(true && comp_0016(arg0[0]) && comp_0016(arg0[1]))); STDOUT.puts("arg0 value error in op42\n"); end
    _ret = ArrayOfC_struct[cons_0010(), cons_0010()]
    return(_ret)
  end

  # SYNOPSIS
  #   op43( arg0, arg1 )
  #
  # ARGS
  #   arg0		{http://dopg.gr.jp/sm11.xsd}F_struct
  #   arg1		{http://dopg.gr.jp/sm11.xsd}ArrayOfC_struct
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #    N/A
  #
  def op43( arg0, arg1 )
    STDOUT.puts("op43\n")
    if (!comp_0017(arg0)); STDOUT.puts("arg0 value error in op43\n"); end
    if (!(true && comp_0018(arg1[0]) && comp_0018(arg1[1]))); STDOUT.puts("arg1 value error in op43\n"); end
    return
  end

  # SYNOPSIS
  #   excop1
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #   arg0		{http://dopg.gr.jp/sm11.xsd}A_except
  #
  def excop1
    STDOUT.puts("excop1\n")
    _exc = cons_0011()
    raise(_exc)
  end

  # SYNOPSIS
  #   excop2
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #   arg0		{http://dopg.gr.jp/sm11.xsd}C_except
  #
  def excop2
    STDOUT.puts("excop2\n")
    _exc = cons_0012()
    raise(_exc)
  end

  # SYNOPSIS
  #   excop3
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #   arg0		{http://dopg.gr.jp/sm11.xsd}F_except1
  #
  def excop3
    STDOUT.puts("excop3\n")
    _exc = cons_0014()
    raise(_exc)
  end

  # SYNOPSIS
  #   excop4
  #
  # ARGS
  #    N/A
  #
  # RETURNS
  #    N/A
  #
  # RAISES
  #   arg0		{http://dopg.gr.jp/sm11.xsd}F_except2
  #
  def excop4
    STDOUT.puts("excop4\n")
    _exc = cons_0017()
    raise(_exc)
  end


  require 'soap/rpcUtils'
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

private

  def comp_0012(_v1)
    return(true &&
	(! _v1.e_boolean()) &&
	(_v1.e_short == -100) &&
	(_v1.e_int == -100000) &&
	(_v1.e_long == -10000000000) &&
	(_v1.e_float == 0.123) &&
	(_v1.e_double == 0.12e3) &&
	(_v1.e_String == "abc")
    )
  end
  def cons_0007()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def comp_0013(_v1)
    return(true &&
	(! _v1.e_boolean()) &&
	(_v1.e_short == -100) &&
	(_v1.e_int == -100000) &&
	(_v1.e_long == -10000000000) &&
	(_v1.e_float == 0.123) &&
	(_v1.e_double == 0.12e3) &&
	(_v1.e_String == "abc")
    )
  end
  def comp_0015(_v1)
    return(true &&
	(! _v1.e_boolean()) &&
	(_v1.e_short == -100) &&
	(_v1.e_int == -100000) &&
	(_v1.e_long == -10000000000) &&
	(_v1.e_float == 0.123) &&
	(_v1.e_double == 0.12e3) &&
	(_v1.e_String == "abc")
    )
  end
  def comp_0014(_v1)
    return(true &&
	comp_0015(_v1.e_c_struct) &&
	(true && (_v1.e_c_array_e_boolean[0] == false) && (_v1.e_c_array_e_boolean[1] == false)) &&
	(true && (_v1.e_c_array_e_short[0] == -100) && (_v1.e_c_array_e_short[1] == -100)) &&
	(true && (_v1.e_c_array_e_int[0] == -100000) && (_v1.e_c_array_e_int[1] == -100000)) &&
	(true && (_v1.e_c_array_e_long[0] == -10000000000) && (_v1.e_c_array_e_long[1] == -10000000000)) &&
	(true && (_v1.e_c_array_e_float[0] == 0.123) && (_v1.e_c_array_e_float[1] == 0.123)) &&
	(true && (_v1.e_c_array_e_double[0] == 0.12e3) && (_v1.e_c_array_e_double[1] == 0.12e3)) &&
	(true && (_v1.e_c_array_e_String[0] == "abc") && (_v1.e_c_array_e_String[1] == "abc"))
    )
  end
  def cons_0009()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def cons_0008()
    _v1 = F_struct.new()
    _v1.e_c_struct = cons_0009()
    _v1.e_c_array_e_boolean = ArrayOfboolean[true, true]
    _v1.e_c_array_e_short = ArrayOfshort[-200, -200]
    _v1.e_c_array_e_int = ArrayOfint[-200000, -200000]
    _v1.e_c_array_e_long = ArrayOflong[-20000000000, -20000000000]
    _v1.e_c_array_e_float = ArrayOffloat[1.234, 1.234]
    _v1.e_c_array_e_double = ArrayOfdouble[1.23e4, 1.23e4]
    _v1.e_c_array_e_String = ArrayOfstring["def", "def"]
    return(_v1)
  end
  def comp_0016(_v1)
    return(true &&
	(! _v1.e_boolean()) &&
	(_v1.e_short == -100) &&
	(_v1.e_int == -100000) &&
	(_v1.e_long == -10000000000) &&
	(_v1.e_float == 0.123) &&
	(_v1.e_double == 0.12e3) &&
	(_v1.e_String == "abc")
    )
  end
  def cons_0010()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def comp_0018(_v1)
    return(true &&
	(! _v1.e_boolean()) &&
	(_v1.e_short == -100) &&
	(_v1.e_int == -100000) &&
	(_v1.e_long == -10000000000) &&
	(_v1.e_float == 0.123) &&
	(_v1.e_double == 0.12e3) &&
	(_v1.e_String == "abc")
    )
  end
  def comp_0017(_v1)
    return(true &&
	comp_0018(_v1.e_c_struct) &&
	(true && (_v1.e_c_array_e_boolean[0] == false) && (_v1.e_c_array_e_boolean[1] == false)) &&
	(true && (_v1.e_c_array_e_short[0] == -100) && (_v1.e_c_array_e_short[1] == -100)) &&
	(true && (_v1.e_c_array_e_int[0] == -100000) && (_v1.e_c_array_e_int[1] == -100000)) &&
	(true && (_v1.e_c_array_e_long[0] == -10000000000) && (_v1.e_c_array_e_long[1] == -10000000000)) &&
	(true && (_v1.e_c_array_e_float[0] == 0.123) && (_v1.e_c_array_e_float[1] == 0.123)) &&
	(true && (_v1.e_c_array_e_double[0] == 0.12e3) && (_v1.e_c_array_e_double[1] == 0.12e3)) &&
	(true && (_v1.e_c_array_e_String[0] == "abc") && (_v1.e_c_array_e_String[1] == "abc"))
    )
  end
  def cons_0011()
    _v1 = A_except.new()
    _v1.v1 = true
    _v1.v4 = SOAPShort.new(-200)
    _v1.v5 = SOAPInt.new(-200000)
    _v1.v6 = SOAPLong.new(-20000000000)
    _v1.v7 = SOAPFloat.new(1.234)
    _v1.v8 = 1.23e4
    _v1.v9 = "def"
    return(_v1)
  end
  def cons_0013()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def cons_0012()
    _v1 = C_except.new()
    _v1.v10 = cons_0013()
    _v1.v21 = ArrayOfboolean[true, true]
    _v1.v24 = ArrayOfshort[-200, -200]
    _v1.v25 = ArrayOfint[-200000, -200000]
    _v1.v26 = ArrayOflong[-20000000000, -20000000000]
    _v1.v27 = ArrayOffloat[1.234, 1.234]
    _v1.v28 = ArrayOfdouble[1.23e4, 1.23e4]
    _v1.v29 = ArrayOfstring["def", "def"]
    return(_v1)
  end
  def cons_0016()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def cons_0015()
    _v1 = F_struct.new()
    _v1.e_c_struct = cons_0016()
    _v1.e_c_array_e_boolean = ArrayOfboolean[true, true]
    _v1.e_c_array_e_short = ArrayOfshort[-200, -200]
    _v1.e_c_array_e_int = ArrayOfint[-200000, -200000]
    _v1.e_c_array_e_long = ArrayOflong[-20000000000, -20000000000]
    _v1.e_c_array_e_float = ArrayOffloat[1.234, 1.234]
    _v1.e_c_array_e_double = ArrayOfdouble[1.23e4, 1.23e4]
    _v1.e_c_array_e_String = ArrayOfstring["def", "def"]
    return(_v1)
  end
  def cons_0014()
    _v1 = F_except1.new()
    _v1.v40 = cons_0015()
    return(_v1)
  end
  def cons_0018()
    _v1 = C_struct.new()
    _v1.e_boolean = true
    _v1.e_short = SOAPShort.new(-200)
    _v1.e_int = SOAPInt.new(-200000)
    _v1.e_long = SOAPLong.new(-20000000000)
    _v1.e_float = SOAPFloat.new(1.234)
    _v1.e_double = 1.23e4
    _v1.e_String = "def"
    return(_v1)
  end
  def cons_0017()
    _v1 = F_except2.new()
    _v1.v50 = ArrayOfC_struct[cons_0018(), cons_0018()]
    return(_v1)
  end

end
