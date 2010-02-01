#!/usr/bin/env ruby

$serverName = 'WhiteMesaSOAPServer'
$serverBase = 'http://www.whitemesa.net/interop/std'
$serverGroupB = 'http://www.whitemesa.net/interop/std/groupB'

$wsdlBase = 'http://www.whitemesa.net/wsdl/std/interop.wsdl'
$wsdlGroupB = 'http://www.whitemesa.net/wsdl/std/interopB.wsdl'

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
drvGroupB = SOAP::WSDLDriverFactory.new($wsdlGroupB).create_rpc_driver
drvGroupB.endpoint_url = $serverGroupB

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
