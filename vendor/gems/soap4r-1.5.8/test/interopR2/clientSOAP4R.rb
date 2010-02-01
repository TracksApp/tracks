#!/usr/bin/env ruby

$serverName = 'SOAP4R'

$server = 'http://dev.ctor.org/soapsrv'
#$server = 'http://rrr.jin.gr.jp/soapsrv'
#$server = 'http://dev.ctor.org/soapsrv'
#$server = 'http://localhost:10080'
#require 'xsd/datatypes1999'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
#submitTestResult
