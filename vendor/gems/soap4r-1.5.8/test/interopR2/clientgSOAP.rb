#!/usr/bin/env ruby

$serverName = 'gSOAP'

$serverBase = 'http://websrv.cs.fsu.edu/~engelen/interop2.cgi'
$serverGroupB = 'http://websrv.cs.fsu.edu/~engelen/interop2B.cgi'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDef(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
