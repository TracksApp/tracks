require 'amazonEc.rb'

require 'soap/rpc/driver'

class AWSECommerceServicePortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://soap.amazon.com/onca/soap?Service=AWSECommerceService"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  Methods = [
    [ "http://soap.amazon.com",
      "help",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Help"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HelpResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "itemSearch",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemSearch"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemSearchResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "itemLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "browseNodeLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "listSearch",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListSearch"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListSearchResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "listLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "customerContentSearch",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentSearch"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentSearchResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "customerContentLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "similarityLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "sellerLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "cartGet",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartGet"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartGetResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "cartCreate",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartCreate"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartCreateResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "cartAdd",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartAdd"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartAddResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "cartModify",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartModify"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartModifyResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "cartClear",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartClear"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartClearResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "transactionLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "sellerListingSearch",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingSearch"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingSearchResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "sellerListingLookup",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingLookup"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingLookupResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ],
    [ "http://soap.amazon.com",
      "multiOperation",
      [ ["in", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MultiOperation"], true],
        ["out", "body", ["::SOAP::SOAPElement", "http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MultiOperationResponse"], true] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
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
