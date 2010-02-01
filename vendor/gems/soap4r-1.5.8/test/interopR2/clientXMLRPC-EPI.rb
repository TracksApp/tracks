#!/usr/bin/env ruby

$serverName = 'XMLRPC-EPI'
$serverBase = 'http://xmlrpc-epi.sourceforge.net/xmlrpc_php/interop-server.php'
#$serverGroupB = 'http://soapinterop.simdb.com/round2B'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase( drvBase )

#drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
