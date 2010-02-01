#!/usr/bin/env ruby

$serverName = 'KafkaXSLTSOAP'

$server = 'http://www.thoughtpost.com/services/interop.asmx'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
