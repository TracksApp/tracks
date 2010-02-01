#!/usr/bin/env ruby

$serverName = 'SQLDataSOAPServer'
$serverBase = 'http://soapclient.com/interop/sqldatainterop.wsdl'
$serverGroupB = 'http://soapclient.com/interop/InteropB.wsdl'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
