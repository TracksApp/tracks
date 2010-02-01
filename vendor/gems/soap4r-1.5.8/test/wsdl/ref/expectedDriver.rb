require 'product.rb'
require 'productMappingRegistry.rb'
require 'soap/rpc/driver'

module WSDL::Ref

class Ref_porttype < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost:17171/"

  Methods = [
    [ "urn:ref:echo",
      "echo",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "urn:ref", "Product-Bag"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "urn:ref", "Creator"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = ProductMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = ProductMappingRegistry::LiteralRegistry
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
