require 'echo_version.rb'
require 'echo_versionMappingRegistry.rb'
require 'soap/rpc/driver'

class Echo_version_port_type < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost:10080"
  NsSimpletypeRpc = "urn:example.com:simpletype-rpc"

  Methods = [
    [ XSD::QName.new(NsSimpletypeRpc, "echo_version"),
      "urn:example.com:simpletype-rpc",
      "echo_version",
      [ ["in", "version", [nil, "urn:example.com:simpletype-rpc-type", "version"]],
        ["retval", "version_struct", ["Version_struct", "urn:example.com:simpletype-rpc-type", "version_struct"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsSimpletypeRpc, "echo_version_r"),
      "urn:example.com:simpletype-rpc",
      "echo_version_r",
      [ ["in", "version_struct", ["Version_struct", "urn:example.com:simpletype-rpc-type", "version_struct"]],
        ["retval", "version", [nil, "urn:example.com:simpletype-rpc-type", "version"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = Echo_versionMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = Echo_versionMappingRegistry::LiteralRegistry
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
