#!/usr/bin/env ruby

$serverName = 'HPSOAP'
$server = 'http://soap.bluestone.com/hpws/soap/EchoService'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTest(drv)
submitTestResult
