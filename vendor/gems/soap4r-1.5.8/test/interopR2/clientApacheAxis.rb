#!/usr/bin/env ruby

$serverName = 'ApacheAxis'
$server = 'http://nagoya.apache.org:5049/axis/services/echo'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
