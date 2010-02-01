#!/usr/bin/env ruby

$serverName = 'CapeConnect'

$server = 'http://interop.capeclear.com/ccx/soapbuilders-round2'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefBase(drvBase)

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB(drvGroupB)

doTestBase(drvBase)
#doTestGroupB(drvGroupB)
submitTestResult
