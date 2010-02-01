#!/usr/bin/env ruby

$serverName = 'IONAXMLBus'

$serverBase = 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/BaseService/BasePort'
$serverGroupB = 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/GroupBService/GroupBPort'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDef(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
