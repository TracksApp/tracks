#!/usr/bin/env ruby

$serverName = 'WASPforC++'

$serverBase = 'http://soap.systinet.net:6070/InteropService/'
$serverGroupB = 'http://soap.systinet.net:6070/InteropBService/'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
