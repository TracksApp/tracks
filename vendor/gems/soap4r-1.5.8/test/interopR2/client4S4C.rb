#!/usr/bin/env ruby

$serverName = '4S4C'
$server = 'http://soap.4s4c.com/ilab/soap.asp'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
