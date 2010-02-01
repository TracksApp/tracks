require 'RAA.rb'
require 'RAAMappingRegistry.rb'
require 'soap/rpc/driver'

module WSDL::RAA

class RAABaseServicePortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://raa.ruby-lang.org/soap/1.0.2/"
  NsC_002 = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"

  Methods = [
    [ XSD::QName.new(NsC_002, "getAllListings"),
      "",
      "getAllListings",
      [ ["retval", "return", ["WSDL::RAA::StringArray", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "StringArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_002, "getProductTree"),
      "",
      "getProductTree",
      [ ["retval", "return", ["Hash", "http://xml.apache.org/xml-soap", "Map"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_002, "getInfoFromCategory"),
      "",
      "getInfoFromCategory",
      [ ["in", "category", ["WSDL::RAA::Category", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Category"]],
        ["retval", "return", ["WSDL::RAA::InfoArray", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_002, "getModifiedInfoSince"),
      "",
      "getModifiedInfoSince",
      [ ["in", "timeInstant", ["::SOAP::SOAPDateTime"]],
        ["retval", "return", ["WSDL::RAA::InfoArray", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_002, "getInfoFromName"),
      "",
      "getInfoFromName",
      [ ["in", "productName", ["::SOAP::SOAPString"]],
        ["retval", "return", ["WSDL::RAA::Info", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_002, "getInfoFromOwnerId"),
      "",
      "getInfoFromOwnerId",
      [ ["in", "ownerId", ["::SOAP::SOAPInt"]],
        ["retval", "return", ["WSDL::RAA::InfoArray", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = RAAMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = RAAMappingRegistry::LiteralRegistry
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
