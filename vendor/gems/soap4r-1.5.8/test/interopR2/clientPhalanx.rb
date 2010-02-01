#!/usr/bin/env ruby

$serverName = 'Phalanx'

$serverBase = 'http://www.phalanxsys.com/ilabA/typed/target.asp'
$serverGroupB = 'http://www.phalanxsys.com/ilabB/typed/target.asp'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
