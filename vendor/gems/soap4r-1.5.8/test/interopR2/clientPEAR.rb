#!/usr/bin/env ruby

$serverName = 'PEAR'

$server = 'http://www.caraveo.com/soap_interop/server_round2.php'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
