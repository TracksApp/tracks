#!/usr/bin/env ruby

$KCODE = "UTF8"      # Set $KCODE before loading 'soap/xmlparser'.

require 'soap/standaloneServer'
require 'servant'

class App < SOAP::StandaloneServer
  def initialize( *arg )
    super( *arg )

    # Explicit definition
    servant = Sm11PortType.new
    Sm11PortType::Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      addMethodWithNSAs( namespace, servant, methodName, methodNameAs, params, soapAction )
    end
    # Easy way to add all methods.
    addServant( Sm11PortType.new )

    self.mappingRegistry = Sm11PortType::MappingRegistry
    self.level = Logger::Severity::ERROR
  end
end

App.new( 'App', nil, '0.0.0.0', 10080 ).start
