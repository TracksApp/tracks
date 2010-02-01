#!/usr/bin/env ruby

$serverName = 'MicrosoftSoapToolkit3.0'
$serverBase = 'http://mssoapinterop.org/stkV3/InteropTyped.wsdl'
$serverGroupB = 'http://mssoapinterop.org/stkV3/InteropBtyped.wsdl'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
