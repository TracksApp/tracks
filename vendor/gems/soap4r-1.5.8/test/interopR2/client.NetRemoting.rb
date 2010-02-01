#!/usr/bin/env ruby

$serverName = 'dotNetRemotingWebServices'
$serverBase = 'http://www.mssoapinterop.org/remoting/ServiceA.soap'
$serverGroupB = 'http://www.mssoapinterop.org/remoting/ServiceB.soap'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
