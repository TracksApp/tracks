#!/usr/bin/env ruby

$serverName = 'eSoap'

$serverBase = 'http://www.quakersoft.net/cgi-bin/interop2_server.cgi'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB(drvGroupB)

doTestBase(drvBase)
#doTestGroupB(drvGroupB)
submitTestResult
