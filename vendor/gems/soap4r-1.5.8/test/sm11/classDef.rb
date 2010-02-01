# http://dopg.gr.jp/sm11.xsd
class C_struct
  attr_accessor :e_boolean	# {http://www.w3.org/2001/XMLSchema}boolean
  attr_accessor :e_short	# {http://www.w3.org/2001/XMLSchema}short
  attr_accessor :e_int	# {http://www.w3.org/2001/XMLSchema}int
  attr_accessor :e_long	# {http://www.w3.org/2001/XMLSchema}long
  attr_accessor :e_float	# {http://www.w3.org/2001/XMLSchema}float
  attr_accessor :e_double	# {http://www.w3.org/2001/XMLSchema}double
  attr_accessor :e_String	# {http://www.w3.org/2001/XMLSchema}string

  def initialize( e_boolean = nil,
      e_short = nil,
      e_int = nil,
      e_long = nil,
      e_float = nil,
      e_double = nil,
      e_String = nil )
    @e_boolean = nil
    @e_short = nil
    @e_int = nil
    @e_long = nil
    @e_float = nil
    @e_double = nil
    @e_String = nil
  end
end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfboolean < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfshort < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfint < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOflong < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOffloat < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfdouble < Array; end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfstring < Array; end

# http://dopg.gr.jp/sm11.xsd
class F_struct
  attr_accessor :e_c_struct	# {http://dopg.gr.jp/sm11.xsd}C_struct
  attr_accessor :e_c_array_e_boolean	# {http://dopg.gr.jp/sm11.xsd}ArrayOfboolean
  attr_accessor :e_c_array_e_short	# {http://dopg.gr.jp/sm11.xsd}ArrayOfshort
  attr_accessor :e_c_array_e_int	# {http://dopg.gr.jp/sm11.xsd}ArrayOfint
  attr_accessor :e_c_array_e_long	# {http://dopg.gr.jp/sm11.xsd}ArrayOflong
  attr_accessor :e_c_array_e_float	# {http://dopg.gr.jp/sm11.xsd}ArrayOffloat
  attr_accessor :e_c_array_e_double	# {http://dopg.gr.jp/sm11.xsd}ArrayOfdouble
  attr_accessor :e_c_array_e_String	# {http://dopg.gr.jp/sm11.xsd}ArrayOfstring

  def initialize( e_c_struct = nil,
      e_c_array_e_boolean = nil,
      e_c_array_e_short = nil,
      e_c_array_e_int = nil,
      e_c_array_e_long = nil,
      e_c_array_e_float = nil,
      e_c_array_e_double = nil,
      e_c_array_e_String = nil )
    @e_c_struct = nil
    @e_c_array_e_boolean = nil
    @e_c_array_e_short = nil
    @e_c_array_e_int = nil
    @e_c_array_e_long = nil
    @e_c_array_e_float = nil
    @e_c_array_e_double = nil
    @e_c_array_e_String = nil
  end
end

# http://dopg.gr.jp/sm11.xsd
class ArrayOfC_struct < Array; end

# http://dopg.gr.jp/sm11.xsd
class A_except < StandardError
  attr_accessor :v1	# {http://www.w3.org/2001/XMLSchema}boolean
  attr_accessor :v4	# {http://www.w3.org/2001/XMLSchema}short
  attr_accessor :v5	# {http://www.w3.org/2001/XMLSchema}int
  attr_accessor :v6	# {http://www.w3.org/2001/XMLSchema}long
  attr_accessor :v7	# {http://www.w3.org/2001/XMLSchema}float
  attr_accessor :v8	# {http://www.w3.org/2001/XMLSchema}double
  attr_accessor :v9	# {http://www.w3.org/2001/XMLSchema}string

  def initialize( v1 = nil,
      v4 = nil,
      v5 = nil,
      v6 = nil,
      v7 = nil,
      v8 = nil,
      v9 = nil )
    @v1 = nil
    @v4 = nil
    @v5 = nil
    @v6 = nil
    @v7 = nil
    @v8 = nil
    @v9 = nil
  end
end

# http://dopg.gr.jp/sm11.xsd
class C_except < StandardError
  attr_accessor :v10	# {http://dopg.gr.jp/sm11.xsd}C_struct
  attr_accessor :v21	# {http://dopg.gr.jp/sm11.xsd}ArrayOfboolean
  attr_accessor :v24	# {http://dopg.gr.jp/sm11.xsd}ArrayOfshort
  attr_accessor :v25	# {http://dopg.gr.jp/sm11.xsd}ArrayOfint
  attr_accessor :v26	# {http://dopg.gr.jp/sm11.xsd}ArrayOflong
  attr_accessor :v27	# {http://dopg.gr.jp/sm11.xsd}ArrayOffloat
  attr_accessor :v28	# {http://dopg.gr.jp/sm11.xsd}ArrayOfdouble
  attr_accessor :v29	# {http://dopg.gr.jp/sm11.xsd}ArrayOfstring

  def initialize( v10 = nil,
      v21 = nil,
      v24 = nil,
      v25 = nil,
      v26 = nil,
      v27 = nil,
      v28 = nil,
      v29 = nil )
    @v10 = nil
    @v21 = nil
    @v24 = nil
    @v25 = nil
    @v26 = nil
    @v27 = nil
    @v28 = nil
    @v29 = nil
  end
end

# http://dopg.gr.jp/sm11.xsd
class F_except1 < StandardError
  attr_accessor :v40	# {http://dopg.gr.jp/sm11.xsd}F_struct

  def initialize( v40 = nil )
    @v40 = nil
  end
end

# http://dopg.gr.jp/sm11.xsd
class F_except2 < StandardError
  attr_accessor :v50	# {http://dopg.gr.jp/sm11.xsd}ArrayOfC_struct

  def initialize( v50 = nil )
    @v50 = nil
  end
end
