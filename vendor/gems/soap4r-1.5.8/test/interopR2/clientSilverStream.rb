#!/usr/bin/env ruby

$serverName = 'SilverStream'

$server = 'http://explorer.ne.mediaone.net/app/interop/interop'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefBase(drvBase)

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB(drvGroupB)

doTestBase(drvBase)
#doTestGroupB(drvGroupB)
submitTestResult
