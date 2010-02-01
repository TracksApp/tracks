#!/usr/bin/env ruby

$serverName = 'VWOpentalkSoap'

$server = 'http://www.cincomsmalltalk.com/soap/interop'
$serverGroupB = 'http://www.cincomsmalltalk.com/r2groupb/interop'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefBase(drv)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drv)
doTestGroupB(drvGroupB)
submitTestResult
