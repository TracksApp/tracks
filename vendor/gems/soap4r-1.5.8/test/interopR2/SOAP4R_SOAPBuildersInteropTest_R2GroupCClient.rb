#!/usr/bin/env ruby
require 'InteropTestDriver.rb'

endpoint_url = ARGV.shift
obj = InteropTestPortType.new(endpoint_url)

# Uncomment the below line to see SOAP wiredumps.
# obj.wiredump_dev = STDERR

# SYNOPSIS
#   echoString(inputString)
#
# ARGS
#   inputString     String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   v_return        String - {http://www.w3.org/2001/XMLSchema}string
#
inputString = nil
puts obj.echoString(inputString)

# SYNOPSIS
#   echoStringArray(inputStringArray)
#
# ARGS
#   inputStringArray ArrayOfstring - {http://soapinterop.org/xsd}ArrayOfstring
#
# RETURNS
#   v_return        ArrayOfstring - {http://soapinterop.org/xsd}ArrayOfstring
#
inputStringArray = nil
puts obj.echoStringArray(inputStringArray)

# SYNOPSIS
#   echoInteger(inputInteger)
#
# ARGS
#   inputInteger    Int - {http://www.w3.org/2001/XMLSchema}int
#
# RETURNS
#   v_return        Int - {http://www.w3.org/2001/XMLSchema}int
#
inputInteger = nil
puts obj.echoInteger(inputInteger)

# SYNOPSIS
#   echoIntegerArray(inputIntegerArray)
#
# ARGS
#   inputIntegerArray ArrayOfint - {http://soapinterop.org/xsd}ArrayOfint
#
# RETURNS
#   v_return        ArrayOfint - {http://soapinterop.org/xsd}ArrayOfint
#
inputIntegerArray = nil
puts obj.echoIntegerArray(inputIntegerArray)

# SYNOPSIS
#   echoFloat(inputFloat)
#
# ARGS
#   inputFloat      Float - {http://www.w3.org/2001/XMLSchema}float
#
# RETURNS
#   v_return        Float - {http://www.w3.org/2001/XMLSchema}float
#
inputFloat = nil
puts obj.echoFloat(inputFloat)

# SYNOPSIS
#   echoFloatArray(inputFloatArray)
#
# ARGS
#   inputFloatArray ArrayOffloat - {http://soapinterop.org/xsd}ArrayOffloat
#
# RETURNS
#   v_return        ArrayOffloat - {http://soapinterop.org/xsd}ArrayOffloat
#
inputFloatArray = nil
puts obj.echoFloatArray(inputFloatArray)

# SYNOPSIS
#   echoStruct(inputStruct)
#
# ARGS
#   inputStruct     SOAPStruct - {http://soapinterop.org/xsd}SOAPStruct
#
# RETURNS
#   v_return        SOAPStruct - {http://soapinterop.org/xsd}SOAPStruct
#
inputStruct = nil
puts obj.echoStruct(inputStruct)

# SYNOPSIS
#   echoStructArray(inputStructArray)
#
# ARGS
#   inputStructArray ArrayOfSOAPStruct - {http://soapinterop.org/xsd}ArrayOfSOAPStruct
#
# RETURNS
#   v_return        ArrayOfSOAPStruct - {http://soapinterop.org/xsd}ArrayOfSOAPStruct
#
inputStructArray = nil
puts obj.echoStructArray(inputStructArray)

# SYNOPSIS
#   echoVoid
#
# ARGS
#   N/A
#
# RETURNS
#   N/A
#

puts obj.echoVoid

# SYNOPSIS
#   echoBase64(inputBase64)
#
# ARGS
#   inputBase64     Base64Binary - {http://www.w3.org/2001/XMLSchema}base64Binary
#
# RETURNS
#   v_return        Base64Binary - {http://www.w3.org/2001/XMLSchema}base64Binary
#
inputBase64 = nil
puts obj.echoBase64(inputBase64)

# SYNOPSIS
#   echoDate(inputDate)
#
# ARGS
#   inputDate       DateTime - {http://www.w3.org/2001/XMLSchema}dateTime
#
# RETURNS
#   v_return        DateTime - {http://www.w3.org/2001/XMLSchema}dateTime
#
inputDate = nil
puts obj.echoDate(inputDate)

# SYNOPSIS
#   echoHexBinary(inputHexBinary)
#
# ARGS
#   inputHexBinary  HexBinary - {http://www.w3.org/2001/XMLSchema}hexBinary
#
# RETURNS
#   v_return        HexBinary - {http://www.w3.org/2001/XMLSchema}hexBinary
#
inputHexBinary = nil
puts obj.echoHexBinary(inputHexBinary)

# SYNOPSIS
#   echoDecimal(inputDecimal)
#
# ARGS
#   inputDecimal    Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#
# RETURNS
#   v_return        Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#
inputDecimal = nil
puts obj.echoDecimal(inputDecimal)

# SYNOPSIS
#   echoBoolean(inputBoolean)
#
# ARGS
#   inputBoolean    Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   v_return        Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
inputBoolean = nil
puts obj.echoBoolean(inputBoolean)
