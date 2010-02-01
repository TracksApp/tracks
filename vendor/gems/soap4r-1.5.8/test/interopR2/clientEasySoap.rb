#!/usr/bin/env ruby

$serverName = 'EasySoap++'

$server = 'http://easysoap.sourceforge.net/cgi-bin/interopserver'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
