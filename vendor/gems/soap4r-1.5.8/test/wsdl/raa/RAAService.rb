#!/usr/bin/env ruby
require 'soap/rpc/standaloneServer'

module WSDL; module RAA

class RAABaseServicePortTypeServer
  def getAllListings
    ["ruby", "soap4r"]
  end

  def getProductTree
    raise NotImplementedError.new
  end

  def getInfoFromCategory(category)
    raise NotImplementedError.new
  end

  def getModifiedInfoSince(timeInstant)
    raise NotImplementedError.new
  end

  def getInfoFromName(productName)
    Info.new(
      Category.new("major", "minor"),
      Product.new(123, productName, "short description", "version", "status",
        URI.parse("http://example.com/homepage"),
        URI.parse("http://example.com/download"),
        "license", "description"),
      Owner.new(456, URI.parse("mailto:email@example.com"), "name"),
      Time.now,
      Time.now)
  end

  def getInfoFromOwnerId(ownerId)
    raise NotImplementedError.new
  end

  Methods = [
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getAllListings"),
      "",
      "getAllListings",
      [ ["retval", "return", ["WSDL::RAA::C_String[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "StringArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getProductTree"),
      "",
      "getProductTree",
      [ ["retval", "return", ["Hash", "http://xml.apache.org/xml-soap", "Map"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromCategory"),
      "",
      "getInfoFromCategory",
      [ ["in", "category", ["WSDL::RAA::Category", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Category"]],
        ["retval", "return", ["WSDL::RAA::Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getModifiedInfoSince"),
      "",
      "getModifiedInfoSince",
      [ ["in", "timeInstant", ["::SOAP::SOAPDateTime"]],
        ["retval", "return", ["WSDL::RAA::Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromName"),
      "",
      "getInfoFromName",
      [ ["in", "productName", ["::SOAP::SOAPString"]],
        ["retval", "return", ["WSDL::RAA::Info", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromOwnerId"),
      "",
      "getInfoFromOwnerId",
      [ ["in", "ownerId", ["::SOAP::SOAPInt"]],
        ["retval", "return", ["WSDL::RAA::Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "InfoArray"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]
end

end; end

module WSDL; module RAA

class RAABaseServicePortTypeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = WSDL::RAA::RAABaseServicePortTypeServer.new
    WSDL::RAA::RAABaseServicePortType::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
      end
    end
    self.mapping_registry = RAAMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = RAAMappingRegistry::LiteralRegistry
  end
end

end; end

if $0 == __FILE__
  # Change listen port.
  server = WSDL::RAA::RAABaseServicePortTypeApp.new('app', nil, '0.0.0.0', 10080)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
