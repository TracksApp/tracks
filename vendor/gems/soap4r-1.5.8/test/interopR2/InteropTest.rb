require 'xsd/qname'

# {http://soapinterop.org/xsd}ArrayOfstring
class ArrayOfstring < ::Array
  @@schema_type = "string"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOfint
class ArrayOfint < ::Array
  @@schema_type = "int"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOffloat
class ArrayOffloat < ::Array
  @@schema_type = "float"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOfSOAPStruct
class ArrayOfSOAPStruct < ::Array
  @@schema_type = "SOAPStruct"
  @@schema_ns = "http://soapinterop.org/xsd"
end

# {http://soapinterop.org/xsd}SOAPStruct
class SOAPStruct
  @@schema_type = "SOAPStruct"
  @@schema_ns = "http://soapinterop.org/xsd"
  @@schema_element = [["varString", "String"], ["varInt", "Int"], ["varFloat", "Float"]]

  attr_accessor :varString
  attr_accessor :varInt
  attr_accessor :varFloat

  def initialize(varString = nil, varInt = nil, varFloat = nil)
    @varString = varString
    @varInt = varInt
    @varFloat = varFloat
  end
end

# {http://soapinterop.org/xsd}ArrayOfstring
class ArrayOfstring < ::Array
  @@schema_type = "string"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOfint
class ArrayOfint < ::Array
  @@schema_type = "int"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOffloat
class ArrayOffloat < ::Array
  @@schema_type = "float"
  @@schema_ns = "http://www.w3.org/2001/XMLSchema"
end

# {http://soapinterop.org/xsd}ArrayOfSOAPStruct
class ArrayOfSOAPStruct < ::Array
  @@schema_type = "SOAPStruct"
  @@schema_ns = "http://soapinterop.org/xsd"
end

# {http://soapinterop.org/xsd}SOAPStruct
class SOAPStruct
  @@schema_type = "SOAPStruct"
  @@schema_ns = "http://soapinterop.org/xsd"
  @@schema_element = [["varString", "String"], ["varInt", "Int"], ["varFloat", "Float"]]

  attr_accessor :varString
  attr_accessor :varInt
  attr_accessor :varFloat

  def initialize(varString = nil, varInt = nil, varFloat = nil)
    @varString = varString
    @varInt = varInt
    @varFloat = varFloat
  end
end
