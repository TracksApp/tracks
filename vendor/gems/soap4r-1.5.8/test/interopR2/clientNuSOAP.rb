#!/usr/bin/env ruby

$serverName = 'NuSOAP'

$serverBase = 'http://dietrich.ganx4.com/nusoap/testbed/round2_base_server.php'
$serverGroupB = 'http://dietrich.ganx4.com/nusoap/testbed/round2_groupb_server.php'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
