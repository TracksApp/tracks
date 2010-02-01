#!/usr/bin/env ruby

$serverName = 'kSOAP'

$serverBase = 'http://kissen.cs.uni-dortmund.de:8080/ksoapinterop'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDef(drvBase)

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB(drvGroupB)

doTestBase(drvBase)
#doTestGroupB(drvGroupB)
submitTestResult
