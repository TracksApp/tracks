# Done
#   /^void/  def/
#   /^}/  end/
#   /System.out.print/STDOUT.puts/g
#   /try { \(.*\) }/\1/
#   /\.set\([^(]*\)(\([^)]*\))/.\1 = \2/
#   /E_/e_/
#   /\.get\([^(]*\)()/.\1/
#   /(short)//
#
require 'soap/baseData'

class Sm11Caller
  include SOAP

  attr_reader :target

  def initialize( target )
    @target = target
  end

private
  def cons_0000()
    _v1 = C_struct.new()
    _v1.e_boolean = false
    _v1.e_short = SOAPShort.new(-100)
    _v1.e_int = SOAPInt.new(-100000)
    _v1.e_long = SOAPLong.new(-10000000000)
    _v1.e_float = SOAPFloat.new(0.123)
    _v1.e_double = 0.12e3
    _v1.e_String = "abc"
    return(_v1)
  end
  def comp_0000(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def cons_0001()
    _v1 = C_struct.new()
    _v1.e_boolean = false
    _v1.e_short = SOAPShort.new(-100)
    _v1.e_int = SOAPInt.new(-100000)
    _v1.e_long = SOAPLong.new(-10000000000)
    _v1.e_float = SOAPFloat.new(0.123)
    _v1.e_double = 0.12e3
    _v1.e_String = "abc"
    return(_v1)
  end
  def cons_0003()
    _v1 = C_struct.new()
    _v1.e_boolean = false
    _v1.e_short = SOAPShort.new(-100)
    _v1.e_int = SOAPInt.new(-100000)
    _v1.e_long = SOAPLong.new(-10000000000)
    _v1.e_float = SOAPFloat.new(0.123)
    _v1.e_double = 0.12e3
    _v1.e_String = "abc"
    return(_v1)
  end
  def cons_0002()
    _v1 = F_struct.new()
    _v1.e_c_struct = cons_0003()
    _v1.e_c_array_e_boolean = ArrayOfboolean[false, false]
    _v1.e_c_array_e_short = ArrayOfshort[-100, -100]
    _v1.e_c_array_e_int = ArrayOfint[-100000, -100000]
    _v1.e_c_array_e_long = ArrayOflong[-10000000000, -10000000000]
    _v1.e_c_array_e_float = ArrayOffloat[0.123, 0.123]
    _v1.e_c_array_e_double = ArrayOfdouble[0.12e3, 0.12e3]
    _v1.e_c_array_e_String = ArrayOfstring["abc", "abc"]
    return(_v1)
  end
  def comp_0002(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def comp_0001(_v1)
    return(true &&
	comp_0002(_v1.e_c_struct) &&
	(true && (_v1.e_c_array_e_boolean[0] == true) && (_v1.e_c_array_e_boolean[1] == true)) &&
	(true && (_v1.e_c_array_e_short[0] == -200) && (_v1.e_c_array_e_short[1] == -200)) &&
	(true && (_v1.e_c_array_e_int[0] == -200000) && (_v1.e_c_array_e_int[1] == -200000)) &&
	(true && (_v1.e_c_array_e_long[0] == -20000000000) && (_v1.e_c_array_e_long[1] == -20000000000)) &&
	(true && (_v1.e_c_array_e_float[0] == 1.234) && (_v1.e_c_array_e_float[1] == 1.234)) &&
	(true && (_v1.e_c_array_e_double[0] == 1.23e4) && (_v1.e_c_array_e_double[1] == 1.23e4)) &&
	(true && (_v1.e_c_array_e_String[0] == "def") && (_v1.e_c_array_e_String[1] == "def"))
    )
  end
  def cons_0004()
    _v1 = C_struct.new()
    _v1.e_boolean = false
    _v1.e_short = SOAPShort.new(-100)
    _v1.e_int = SOAPInt.new(-100000)
    _v1.e_long = SOAPLong.new(-10000000000)
    _v1.e_float = SOAPFloat.new(0.123)
    _v1.e_double = 0.12e3
    _v1.e_String = "abc"
    return(_v1)
  end
  def comp_0003(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def cons_0006()
    _v1 = C_struct.new()
    _v1.e_boolean = false
    _v1.e_short = SOAPShort.new(-100)
    _v1.e_int = SOAPInt.new(-100000)
    _v1.e_long = SOAPLong.new(-10000000000)
    _v1.e_float = SOAPFloat.new(0.123)
    _v1.e_double = 0.12e3
    _v1.e_String = "abc"
    return(_v1)
  end
  def cons_0005()
    _v1 = F_struct.new()
    _v1.e_c_struct = cons_0006()
    _v1.e_c_array_e_boolean = ArrayOfboolean[false, false]
    _v1.e_c_array_e_short = ArrayOfshort[-100, -100]
    _v1.e_c_array_e_int = ArrayOfint[-100000, -100000]
    _v1.e_c_array_e_long = ArrayOflong[-10000000000, -10000000000]
    _v1.e_c_array_e_float = ArrayOffloat[0.123, 0.123]
    _v1.e_c_array_e_double = ArrayOfdouble[0.12e3, 0.12e3]
    _v1.e_c_array_e_String = ArrayOfstring["abc", "abc"]
    return(_v1)
  end
  def comp_0004(_v1)
    return(true &&
	(_v1.v1()) &&
	(_v1.v4 == -200) &&
	(_v1.v5 == -200000) &&
	(_v1.v6 == -20000000000) &&
	(_v1.v7 == 1.234) &&
	(_v1.v8 == 1.23e4) &&
	(_v1.v9 == "def")
    )
  end
  def comp_0006(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def comp_0005(_v1)
    return(true &&
	comp_0006(_v1.v10) &&
	(true && (_v1.v21[0] == true) && (_v1.v21[1] == true)) &&
	(true && (_v1.v24[0] == -200) && (_v1.v24[1] == -200)) &&
	(true && (_v1.v25[0] == -200000) && (_v1.v25[1] == -200000)) &&
	(true && (_v1.v26[0] == -20000000000) && (_v1.v26[1] == -20000000000)) &&
	(true && (_v1.v27[0] == 1.234) && (_v1.v27[1] == 1.234)) &&
	(true && (_v1.v28[0] == 1.23e4) && (_v1.v28[1] == 1.23e4)) &&
	(true && (_v1.v29[0] == "def") && (_v1.v29[1] == "def"))
    )
  end
  def comp_0009(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def comp_0008(_v1)
    return(true &&
	comp_0009(_v1.e_c_struct) &&
	(true && (_v1.e_c_array_e_boolean[0] == true) && (_v1.e_c_array_e_boolean[1] == true)) &&
	(true && (_v1.e_c_array_e_short[0] == -200) && (_v1.e_c_array_e_short[1] == -200)) &&
	(true && (_v1.e_c_array_e_int[0] == -200000) && (_v1.e_c_array_e_int[1] == -200000)) &&
	(true && (_v1.e_c_array_e_long[0] == -20000000000) && (_v1.e_c_array_e_long[1] == -20000000000)) &&
	(true && (_v1.e_c_array_e_float[0] == 1.234) && (_v1.e_c_array_e_float[1] == 1.234)) &&
	(true && (_v1.e_c_array_e_double[0] == 1.23e4) && (_v1.e_c_array_e_double[1] == 1.23e4)) &&
	(true && (_v1.e_c_array_e_String[0] == "def") && (_v1.e_c_array_e_String[1] == "def"))
    )
  end
  def comp_0007(_v1)
    return(true &&
	comp_0008(_v1.v40)
    )
  end
  def comp_0011(_v1)
    return(true &&
	(_v1.e_boolean()) &&
	(_v1.e_short == -200) &&
	(_v1.e_int == -200000) &&
	(_v1.e_long == -20000000000) &&
	(_v1.e_float == 1.234) &&
	(_v1.e_double == 1.23e4) &&
	(_v1.e_String == "def")
    )
  end
  def comp_0010(_v1)
    return(true &&
	(true && comp_0011(_v1.v50[0]) && comp_0011(_v1.v50[1]))
    )
  end

  def call_op0()
    STDOUT.puts("op0\n")
    target.op0()
  end
  def call_op1()
    STDOUT.puts("op1\n")
    a1 = false
    target.op1(a1)
  end
  def call_op4()
    STDOUT.puts("op4\n")
    a1 = SOAPShort.new(-100)
    target.op4(a1)
  end
  def call_op5()
    STDOUT.puts("op5\n")
    a1 = -100000
    target.op5(a1)
  end
  def call_op6()
    STDOUT.puts("op6\n")
    a1 = -10000000000
    target.op6(a1)
  end
  def call_op7()
    STDOUT.puts("op7\n")
    a1 = SOAPFloat.new(0.123)
    target.op7(a1)
  end
  def call_op8()
    STDOUT.puts("op8\n")
    a1 = 0.12e3
    target.op8(a1)
  end
  def call_op9()
    STDOUT.puts("op9\n")
    a1 = "abc"
    target.op9(a1)
  end
  def call_op11()
    STDOUT.puts("op11\n")
    _ret = target.op11()
    raise unless _ret.is_a?( TrueClass )
    if (!(_ret == true)); STDOUT.puts("_ret value error in op11\n"); end
  end
  def call_op14()
    STDOUT.puts("op14\n")
    _ret = target.op14()
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -200)); STDOUT.puts("_ret value error in op14\n"); end
  end
  def call_op15()
    STDOUT.puts("op15\n")
    _ret = target.op15()
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -200000)); STDOUT.puts("_ret value error in op15\n"); end
  end
  def call_op16()
    STDOUT.puts("op16\n")
    _ret = target.op16()
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -20000000000)); STDOUT.puts("_ret value error in op16\n"); end
  end
  def call_op17()
    STDOUT.puts("op17\n")
    _ret = target.op17()
    raise unless _ret.is_a?( Float )
    if (!(_ret == 1.234)); STDOUT.puts("_ret value error in op17\n"); end
  end
  def call_op18()
    STDOUT.puts("op18\n")
    _ret = target.op18()
    raise unless _ret.is_a?( Float )
    if (!(_ret == 1.23e4)); STDOUT.puts("_ret value error in op18\n"); end
  end
  def call_op19()
    STDOUT.puts("op19\n")
    _ret = target.op19()
    raise unless _ret.is_a?( String )
    if (!(_ret == "def")); STDOUT.puts("_ret value error in op19\n"); end
  end
  def call_op21()
    STDOUT.puts("op21\n")
    a1 = false
    _ret = target.op21(a1)
    raise unless _ret.is_a?( TrueClass ) or _ret.is_a?( FalseClass )
    if (!(_ret == true)); STDOUT.puts("_ret value error in op21\n"); end
  end
  def call_op24()
    STDOUT.puts("op24\n")
    a1 = SOAPShort.new(-100)
    a2 = SOAPInt.new(-100000)
    a3 = SOAPLong.new(-10000000000)
    _ret = target.op24(a1,a2,a3)
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -200)); STDOUT.puts("_ret value error in op24\n"); end
  end
  def call_op25()
    STDOUT.puts("op25\n")
    a1 = SOAPInt.new(-100000)
    a2 = SOAPLong.new(-10000000000)
    a3 = SOAPFloat.new(0.123)
    _ret = target.op25(a1,a2,a3)
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -200000)); STDOUT.puts("_ret value error in op25\n"); end
  end
  def call_op26()
    STDOUT.puts("op26\n")
    a1 = SOAPLong.new(-10000000000)
    a2 = SOAPFloat.new(0.123)
    a3 = 0.12e3
    _ret = target.op26(a1,a2,a3)
    raise unless _ret.is_a?( Integer )
    if (!(_ret == -20000000000)); STDOUT.puts("_ret value error in op26\n"); end
  end
  def call_op27()
    STDOUT.puts("op27\n")
    a1 = SOAPFloat.new(0.123)
    a2 = 0.12e3
    a3 = "abc"
    _ret = target.op27(a1,a2,a3)
    raise unless _ret.is_a?( Float )
    if (!(_ret == 1.234)); STDOUT.puts("_ret value error in op27\n"); end
  end
  def call_op28()
    STDOUT.puts("op28\n")
    a1 = 0.12e3
    a2 = "abc"
    a3 = false
    _ret = target.op28(a1,a2,a3)
    raise unless _ret.is_a?( Float )
    if (!(_ret == 1.23e4)); STDOUT.puts("_ret value error in op28\n"); end
  end
  def call_op29()
    STDOUT.puts("op29\n")
    a1 = "abc"
    a2 = false
    _ret = target.op29(a1,a2)
    raise unless _ret.is_a?( String )
    if (!(_ret == "def")); STDOUT.puts("_ret value error in op29\n"); end
  end
  def call_op30()
    STDOUT.puts("op30\n")
    a1 = cons_0000()
    _ret = target.op30(a1)
    if (!comp_0000(_ret)); STDOUT.puts("_ret value error in op30\n"); end
  end
  def call_op31()
    STDOUT.puts("op31\n")
    a1 = ArrayOfboolean[false, false]
    _ret = target.op31(a1)
    if (!(true && (_ret[0] == true) && (_ret[1] == true))); STDOUT.puts("_ret value error in op31\n"); end
  end
  def call_op34()
    STDOUT.puts("op34\n")
    a1 = ArrayOfshort[-100, -100]
    _ret = target.op34(a1)
    if (!(true && (_ret[0] == -200) && (_ret[1] == -200))); STDOUT.puts("_ret value error in op34\n"); end
  end
  def call_op35()
    STDOUT.puts("op35\n")
    a1 = ArrayOfint[-100000, -100000]
    _ret = target.op35(a1)
    if (!(true && (_ret[0] == -200000) && (_ret[1] == -200000))); STDOUT.puts("_ret value error in op35\n"); end
  end
  def call_op36()
    STDOUT.puts("op36\n")
    a1 = ArrayOflong[-10000000000, -10000000000]
    _ret = target.op36(a1)
    if (!(true && (_ret[0] == -20000000000) && (_ret[1] == -20000000000))); STDOUT.puts("_ret value error in op36\n"); end
  end
  def call_op37()
    STDOUT.puts("op37\n")
    a1 = ArrayOffloat[0.123, 0.123]
    _ret = target.op37(a1)
    if (!(true && (_ret[0] == 1.234) && (_ret[1] == 1.234))); STDOUT.puts("_ret value error in op37\n"); end
  end
  def call_op38()
    STDOUT.puts("op38\n")
    a1 = ArrayOfdouble[0.12e3, 0.12e3]
    _ret = target.op38(a1)
    if (!(true && (_ret[0] == 1.23e4) && (_ret[1] == 1.23e4))); STDOUT.puts("_ret value error in op38\n"); end
  end
  def call_op39()
    STDOUT.puts("op39\n")
    a1 = ArrayOfstring["abc", "abc"]
    _ret = target.op39(a1)
    if (!(true && (_ret[0] == "def") && (_ret[1] == "def"))); STDOUT.puts("_ret value error in op39\n"); end
  end
  def call_op40()
    STDOUT.puts("op40\n")
    a1 = cons_0001()
    a2 = ArrayOfboolean[false, false]
    a3 = ArrayOfint[-100000, -100000]
    a4 = ArrayOfdouble[0.12e3, 0.12e3]
    a5 = ArrayOfstring["abc", "abc"]
    target.op40(a1,a2,a3,a4,a5)
  end
  def call_op41()
    STDOUT.puts("op41\n")
    a1 = cons_0002()
    _ret = target.op41(a1)
    if (!comp_0001(_ret)); STDOUT.puts("_ret value error in op41\n"); end
  end
  def call_op42()
    STDOUT.puts("op42\n")
    a1 = ArrayOfC_struct[cons_0004(), cons_0004()]
    _ret = target.op42(a1)
    if (!(true && comp_0003(_ret[0]) && comp_0003(_ret[1]))); STDOUT.puts("_ret value error in op42\n"); end
  end
  def call_op43()
    STDOUT.puts("op43\n")
    a1 = cons_0005()
    a2 = ArrayOfC_struct[cons_0006(), cons_0006()]
    target.op43(a1,a2)
  end
  def call_excop1()
    STDOUT.puts("excop1\n")
    begin
      target.excop1()
    rescue A_except => _exc
        if (!comp_0004(_exc)); STDOUT.puts("_exc value error in excop1\n"); end
        return
    end
    STDOUT.puts("no exception raised in excop1\n")
  end
  def call_excop2()
    STDOUT.puts("excop2\n")
    begin
      target.excop2()
    rescue C_except => _exc
        if (!comp_0005(_exc)); STDOUT.puts("_exc value error in excop2\n"); end
        return
    end
    STDOUT.puts("no exception raised in excop2\n")
  end
  def call_excop3()
    STDOUT.puts("excop3\n")
    begin
      target.excop3()
    rescue F_except1 => _exc
        if (!comp_0007(_exc)); STDOUT.puts("_exc value error in excop3\n"); end
        return
    end
    STDOUT.puts("no exception raised in excop3\n")
  end
  def call_excop4()
    STDOUT.puts("excop4\n")
    begin
      target.excop4()
    rescue F_except2 => _exc
        if (!comp_0010(_exc)); STDOUT.puts("_exc value error in excop4\n"); end
        return
    end
    STDOUT.puts("no exception raised in excop4\n")
  end

public

  def dispatcher(argv, start, argc)
    all = (start == argc)
    i = all ? start-1 : start
    while (i < argc) do
        if (all || ("op0" == argv[i])); call_op0(); end
        if (all || ("op1" == argv[i])); call_op1(); end
        if (all || ("op4" == argv[i])); call_op4(); end
        if (all || ("op5" == argv[i])); call_op5(); end
        if (all || ("op6" == argv[i])); call_op6(); end
        if (all || ("op7" == argv[i])); call_op7(); end
        if (all || ("op8" == argv[i])); call_op8(); end
        if (all || ("op9" == argv[i])); call_op9(); end
        if (all || ("op11" == argv[i])); call_op11(); end
        if (all || ("op14" == argv[i])); call_op14(); end
        if (all || ("op15" == argv[i])); call_op15(); end
        if (all || ("op16" == argv[i])); call_op16(); end
        if (all || ("op17" == argv[i])); call_op17(); end
        if (all || ("op18" == argv[i])); call_op18(); end
        if (all || ("op19" == argv[i])); call_op19(); end
        if (all || ("op21" == argv[i])); call_op21(); end
        if (all || ("op24" == argv[i])); call_op24(); end
        if (all || ("op25" == argv[i])); call_op25(); end
        if (all || ("op26" == argv[i])); call_op26(); end
        if (all || ("op27" == argv[i])); call_op27(); end
        if (all || ("op28" == argv[i])); call_op28(); end
        if (all || ("op29" == argv[i])); call_op29(); end
        if (all || ("op30" == argv[i])); call_op30(); end
        if (all || ("op31" == argv[i])); call_op31(); end
        if (all || ("op34" == argv[i])); call_op34(); end
        if (all || ("op35" == argv[i])); call_op35(); end
        if (all || ("op36" == argv[i])); call_op36(); end
        if (all || ("op37" == argv[i])); call_op37(); end
        if (all || ("op38" == argv[i])); call_op38(); end
        if (all || ("op39" == argv[i])); call_op39(); end
        if (all || ("op40" == argv[i])); call_op40(); end
        if (all || ("op41" == argv[i])); call_op41(); end
        if (all || ("op42" == argv[i])); call_op42(); end
        if (all || ("op43" == argv[i])); call_op43(); end
        if (all || ("excop1" == argv[i])); call_excop1(); end
        if (all || ("excop2" == argv[i])); call_excop2(); end
        if (all || ("excop3" == argv[i])); call_excop3(); end
        if (all || ("excop4" == argv[i])); call_excop4(); end

        i += 1
    end
  end

end


#url = "http://localhost:10080/"
#url = "http://16.175.170.131:8080/axis/services/sm11Port"
#url = "http://16.175.170.131/soapsrv"
url = ARGV.shift
require 'driver'
drv = Sm11PortType.new( url )
#drv.setWireDumpDev( STDOUT )
Sm11Caller.new( drv ).dispatcher( ARGV, 0, ARGV.size )
