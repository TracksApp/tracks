#!/usr/bin/env ruby

$serverName = 'SIM'
$serverBase = 'http://soapinterop.simdb.com/round2'
$serverGroupB = 'http://soapinterop.simdb.com/round2B'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
