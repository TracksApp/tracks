#!/usr/bin/env ruby

$serverName = 'Delphi'

$serverBase = 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropService.exe/soap/InteropTestPortType'
$serverGroupB = 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropGroupB.exe/soap/InteropTestPortTypeB'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
