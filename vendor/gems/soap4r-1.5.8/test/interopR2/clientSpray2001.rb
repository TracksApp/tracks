#!/usr/bin/env ruby

$serverName = 'Spray2001'
$serverBase = 'http://www.dolphinharbor.org/services/interop2001'
$serverGroupB = 'http://www.dolphinharbor.org/services/interopB2001'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDef(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
