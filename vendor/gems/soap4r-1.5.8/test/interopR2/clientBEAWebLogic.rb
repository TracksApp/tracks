#!/usr/bin/env ruby

$serverName = 'BEAWebLogic8.1'
$serverBase = 'http://webservice.bea.com:7001/base/SoapInteropBaseService'
$serverGroupB = 'http://webservice.bea.com:7001/groupb/SoapInteropGroupBService'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
