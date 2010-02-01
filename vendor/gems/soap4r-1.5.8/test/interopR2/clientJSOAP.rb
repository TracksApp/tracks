#!/usr/bin/env ruby

$serverName = 'SpheonJSOAP'
$server = 'http://soap.fmui.de/RPC'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
