require 'echo.rb'
require 'echoMappingRegistry.rb'
require 'soap/rpc/driver'

module WSDL::Any

class Echo_port_type < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost:10080"
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

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = EchoMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end


end
