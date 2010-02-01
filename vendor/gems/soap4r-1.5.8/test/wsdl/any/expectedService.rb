#!/usr/bin/env ruby
require 'echoServant.rb'
require 'echoMappingRegistry.rb'
require 'soap/rpc/standaloneServer'

module WSDL; module Any

class Echo_port_type
  NsEcho = "urn:example.com:echo"

  Methods = [
    [ "urn:example.com:echo",
      "echo",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "foo.bar"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "foo.bar"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsEcho, "echoAny"),
      "urn:example.com:echoAny",
      "echoAny",
      [ ["retval", "echoany_return", [nil]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ "urn:example.com:echo",
      "setOutputAndComplete",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "setOutputAndCompleteRequest"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "setOutputAndCompleteRequest"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]
end

end; end

module WSDL; module Any

class Echo_port_typeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = WSDL::Any::Echo_port_type.new
    WSDL::Any::Echo_port_type::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
      end
    end
    self.mapping_registry = EchoMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
  end
end

end; end

if $0 == __FILE__
  # Change listen port.
  server = WSDL::Any::Echo_port_typeApp.new('app', nil, '0.0.0.0', 10080)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
