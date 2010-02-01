#!/usr/bin/env ruby

$serverName = 'GLUE'

$serverBase = 'http://www.themindelectric.net:8005/glue/round2'
$serverGroupB = 'http://www.themindelectric.net:8005/glue/round2B'

$wsdlBase = 'http://www.themindelectric.net:8005/glue/round2.wsdl'
$wsdlGroupB = 'http://www.themindelectric.net:8005/glue/round2B.wsdl'

$noEchoMap = true

require 'clientBase'

=begin
drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)
=end

require 'soap/wsdlDriver'
drvBase = SOAP::WSDLDriverFactory.new($wsdlBase).create_rpc_driver
drvBase.endpoint_url = $serverBase
drvBase.wiredump_dev = STDOUT
drvGroupB = SOAP::WSDLDriverFactory.new($wsdlGroupB).create_rpc_driver
drvGroupB.endpoint_url = $serverGroupB

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
