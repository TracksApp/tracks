#!/usr/bin/env ruby

$serverName = 'Frontier'

$serverBase = 'http://www.soapware.org/xmethodsInterop'

#$wsdlBase = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/SOAP4R_SOAPBuildersInteropTest_R2base.wsdl'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB(drvGroupB)

=begin
require 'soap/wsdlDriver'
drvBase = SOAP::WSDLDriverFactory.new($wsdlBase).create_rpc_driver
drvBase.endpoint_url = $serverBase
=end

doTestBase(drvBase)
#doTestGroupB(drvGroupB)
submitTestResult
