#!/usr/bin/env ruby

$serverName = 'WASPforJava'

$serverBase = 'http://soap.systinet.net:6060/InteropService/'
$serverGroupB = 'http://soap.systinet.net:6060/InteropBService/'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
