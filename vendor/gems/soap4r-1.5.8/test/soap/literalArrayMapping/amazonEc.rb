require 'xsd/qname'

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Bin
class Bin
  @@schema_type = "Bin"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["binName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BinName")]],
    ["binItemCount", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BinItemCount")]],
    ["binParameter", ["[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BinParameter")]]
  ]

  attr_accessor :binName
  attr_accessor :binItemCount
  attr_accessor :binParameter

  def initialize(binName = nil, binItemCount = nil, binParameter = [])
    @binName = binName
    @binItemCount = binItemCount
    @binParameter = binParameter
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SearchBinSet
class SearchBinSet
  @@schema_type = "SearchBinSet"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_attribute = {
    XSD::QName.new(nil, "NarrowBy") => "SOAP::SOAPString"
  }
  @@schema_element = [
    ["bin", ["Bin[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Bin")]]
  ]

  attr_accessor :bin

  def xmlattr_NarrowBy
    (@__xmlattr ||= {})[XSD::QName.new(nil, "NarrowBy")]
  end

  def xmlattr_NarrowBy=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "NarrowBy")] = value
  end

  def initialize(bin = [])
    @bin = bin
    @__xmlattr = {}
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SearchBinSets
class SearchBinSets < ::Array
  @@schema_element = [
    ["SearchBinSet", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchBinSet")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Help
class Help
  @@schema_type = "Help"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["shared", ["HelpRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["HelpRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemSearch
class ItemSearch
  @@schema_type = "ItemSearch"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["shared", ["ItemSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["ItemSearchRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :xMLEscaping
  attr_accessor :validate
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, xMLEscaping = nil, validate = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @xMLEscaping = xMLEscaping
    @validate = validate
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemLookup
class ItemLookup
  @@schema_type = "ItemLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["ItemLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["ItemLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListSearch
class ListSearch
  @@schema_type = "ListSearch"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["ListSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["ListSearchRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListLookup
class ListLookup
  @@schema_type = "ListLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["ListLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["ListLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentSearch
class CustomerContentSearch
  @@schema_type = "CustomerContentSearch"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CustomerContentSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CustomerContentSearchRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentLookup
class CustomerContentLookup
  @@schema_type = "CustomerContentLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CustomerContentLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CustomerContentLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SimilarityLookup
class SimilarityLookup
  @@schema_type = "SimilarityLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["SimilarityLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["SimilarityLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerLookup
class SellerLookup
  @@schema_type = "SellerLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["SellerLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["SellerLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartGet
class CartGet
  @@schema_type = "CartGet"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CartGetRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CartGetRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartAdd
class CartAdd
  @@schema_type = "CartAdd"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CartAddRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CartAddRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartCreate
class CartCreate
  @@schema_type = "CartCreate"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CartCreateRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CartCreateRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartModify
class CartModify
  @@schema_type = "CartModify"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CartModifyRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CartModifyRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartClear
class CartClear
  @@schema_type = "CartClear"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["CartClearRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["CartClearRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}TransactionLookup
class TransactionLookup
  @@schema_type = "TransactionLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["TransactionLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["TransactionLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingSearch
class SellerListingSearch
  @@schema_type = "SellerListingSearch"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["SellerListingSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["SellerListingSearchRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingLookup
class SellerListingLookup
  @@schema_type = "SellerListingLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["SellerListingLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["SellerListingLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}BrowseNodeLookup
class BrowseNodeLookup
  @@schema_type = "BrowseNodeLookup"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["marketplaceDomain", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MarketplaceDomain")]],
    ["aWSAccessKeyId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AWSAccessKeyId")]],
    ["subscriptionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionId")]],
    ["associateTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AssociateTag")]],
    ["validate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Validate")]],
    ["xMLEscaping", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "XMLEscaping")]],
    ["shared", ["BrowseNodeLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shared")]],
    ["request", ["BrowseNodeLookupRequest[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]]
  ]

  attr_accessor :marketplaceDomain
  attr_accessor :aWSAccessKeyId
  attr_accessor :subscriptionId
  attr_accessor :associateTag
  attr_accessor :validate
  attr_accessor :xMLEscaping
  attr_accessor :shared
  attr_accessor :request

  def initialize(marketplaceDomain = nil, aWSAccessKeyId = nil, subscriptionId = nil, associateTag = nil, validate = nil, xMLEscaping = nil, shared = nil, request = [])
    @marketplaceDomain = marketplaceDomain
    @aWSAccessKeyId = aWSAccessKeyId
    @subscriptionId = subscriptionId
    @associateTag = associateTag
    @validate = validate
    @xMLEscaping = xMLEscaping
    @shared = shared
    @request = request
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Condition
class Condition < ::String
  @@schema_type = "Condition"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"

  All = Condition.new("All")
  Collectible = Condition.new("Collectible")
  New = Condition.new("New")
  Refurbished = Condition.new("Refurbished")
  Used = Condition.new("Used")
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}DeliveryMethod
class DeliveryMethod < ::String
  @@schema_type = "DeliveryMethod"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"

  ISPU = DeliveryMethod.new("ISPU")
  Ship = DeliveryMethod.new("Ship")
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}AudienceRating
class AudienceRating < ::String
  @@schema_type = "AudienceRating"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"

  C_12 = AudienceRating.new("12")
  C_16 = AudienceRating.new("16")
  C_18 = AudienceRating.new("18")
  C_6 = AudienceRating.new("6")
  FamilyViewing = AudienceRating.new("FamilyViewing")
  G = AudienceRating.new("G")
  NC17 = AudienceRating.new("NC-17")
  NR = AudienceRating.new("NR")
  PG = AudienceRating.new("PG")
  PG13 = AudienceRating.new("PG-13")
  R = AudienceRating.new("R")
  Unrated = AudienceRating.new("Unrated")
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}MultiOperation
class MultiOperation
  @@schema_type = "MultiOperation"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["help", ["Help", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Help")]],
    ["itemSearch", ["ItemSearch", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemSearch")]],
    ["itemLookup", ["ItemLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemLookup")]],
    ["listSearch", ["ListSearch", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListSearch")]],
    ["listLookup", ["ListLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListLookup")]],
    ["customerContentSearch", ["CustomerContentSearch", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentSearch")]],
    ["customerContentLookup", ["CustomerContentLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentLookup")]],
    ["similarityLookup", ["SimilarityLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityLookup")]],
    ["sellerLookup", ["SellerLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLookup")]],
    ["cartGet", ["CartGet", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartGet")]],
    ["cartAdd", ["CartAdd", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartAdd")]],
    ["cartCreate", ["CartCreate", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartCreate")]],
    ["cartModify", ["CartModify", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartModify")]],
    ["cartClear", ["CartClear", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartClear")]],
    ["transactionLookup", ["TransactionLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionLookup")]],
    ["sellerListingSearch", ["SellerListingSearch", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingSearch")]],
    ["sellerListingLookup", ["SellerListingLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingLookup")]],
    ["browseNodeLookup", ["BrowseNodeLookup", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeLookup")]]
  ]

  attr_accessor :help
  attr_accessor :itemSearch
  attr_accessor :itemLookup
  attr_accessor :listSearch
  attr_accessor :listLookup
  attr_accessor :customerContentSearch
  attr_accessor :customerContentLookup
  attr_accessor :similarityLookup
  attr_accessor :sellerLookup
  attr_accessor :cartGet
  attr_accessor :cartAdd
  attr_accessor :cartCreate
  attr_accessor :cartModify
  attr_accessor :cartClear
  attr_accessor :transactionLookup
  attr_accessor :sellerListingSearch
  attr_accessor :sellerListingLookup
  attr_accessor :browseNodeLookup

  def initialize(help = nil, itemSearch = nil, itemLookup = nil, listSearch = nil, listLookup = nil, customerContentSearch = nil, customerContentLookup = nil, similarityLookup = nil, sellerLookup = nil, cartGet = nil, cartAdd = nil, cartCreate = nil, cartModify = nil, cartClear = nil, transactionLookup = nil, sellerListingSearch = nil, sellerListingLookup = nil, browseNodeLookup = nil)
    @help = help
    @itemSearch = itemSearch
    @itemLookup = itemLookup
    @listSearch = listSearch
    @listLookup = listLookup
    @customerContentSearch = customerContentSearch
    @customerContentLookup = customerContentLookup
    @similarityLookup = similarityLookup
    @sellerLookup = sellerLookup
    @cartGet = cartGet
    @cartAdd = cartAdd
    @cartCreate = cartCreate
    @cartModify = cartModify
    @cartClear = cartClear
    @transactionLookup = transactionLookup
    @sellerListingSearch = sellerListingSearch
    @sellerListingLookup = sellerListingLookup
    @browseNodeLookup = browseNodeLookup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}HelpResponse
class HelpResponse
  @@schema_type = "HelpResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["information", ["Information[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Information")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :information

  def initialize(operationRequest = nil, information = [])
    @operationRequest = operationRequest
    @information = information
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemSearchResponse
class ItemSearchResponse
  @@schema_type = "ItemSearchResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["items", ["Items[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :items

  def initialize(operationRequest = nil, items = [])
    @operationRequest = operationRequest
    @items = items
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemLookupResponse
class ItemLookupResponse
  @@schema_type = "ItemLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["items", ["Items[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :items

  def initialize(operationRequest = nil, items = [])
    @operationRequest = operationRequest
    @items = items
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListSearchResponse
class ListSearchResponse
  @@schema_type = "ListSearchResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["lists", ["Lists[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Lists")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :lists

  def initialize(operationRequest = nil, lists = [])
    @operationRequest = operationRequest
    @lists = lists
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListLookupResponse
class ListLookupResponse
  @@schema_type = "ListLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["lists", ["Lists[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Lists")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :lists

  def initialize(operationRequest = nil, lists = [])
    @operationRequest = operationRequest
    @lists = lists
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentSearchResponse
class CustomerContentSearchResponse
  @@schema_type = "CustomerContentSearchResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["customers", ["Customers[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Customers")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :customers

  def initialize(operationRequest = nil, customers = [])
    @operationRequest = operationRequest
    @customers = customers
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentLookupResponse
class CustomerContentLookupResponse
  @@schema_type = "CustomerContentLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["customers", ["Customers[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Customers")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :customers

  def initialize(operationRequest = nil, customers = [])
    @operationRequest = operationRequest
    @customers = customers
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SimilarityLookupResponse
class SimilarityLookupResponse
  @@schema_type = "SimilarityLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["items", ["Items[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :items

  def initialize(operationRequest = nil, items = [])
    @operationRequest = operationRequest
    @items = items
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerLookupResponse
class SellerLookupResponse
  @@schema_type = "SellerLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["sellers", ["Sellers[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Sellers")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :sellers

  def initialize(operationRequest = nil, sellers = [])
    @operationRequest = operationRequest
    @sellers = sellers
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartGetResponse
class CartGetResponse
  @@schema_type = "CartGetResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["cart", ["Cart[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cart")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :cart

  def initialize(operationRequest = nil, cart = [])
    @operationRequest = operationRequest
    @cart = cart
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartAddResponse
class CartAddResponse
  @@schema_type = "CartAddResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["cart", ["Cart[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cart")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :cart

  def initialize(operationRequest = nil, cart = [])
    @operationRequest = operationRequest
    @cart = cart
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartCreateResponse
class CartCreateResponse
  @@schema_type = "CartCreateResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["cart", ["Cart[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cart")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :cart

  def initialize(operationRequest = nil, cart = [])
    @operationRequest = operationRequest
    @cart = cart
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartModifyResponse
class CartModifyResponse
  @@schema_type = "CartModifyResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["cart", ["Cart[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cart")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :cart

  def initialize(operationRequest = nil, cart = [])
    @operationRequest = operationRequest
    @cart = cart
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartClearResponse
class CartClearResponse
  @@schema_type = "CartClearResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["cart", ["Cart[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cart")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :cart

  def initialize(operationRequest = nil, cart = [])
    @operationRequest = operationRequest
    @cart = cart
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}TransactionLookupResponse
class TransactionLookupResponse
  @@schema_type = "TransactionLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["transactions", ["Transactions[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Transactions")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :transactions

  def initialize(operationRequest = nil, transactions = [])
    @operationRequest = operationRequest
    @transactions = transactions
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingSearchResponse
class SellerListingSearchResponse
  @@schema_type = "SellerListingSearchResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["sellerListings", ["SellerListings[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListings")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :sellerListings

  def initialize(operationRequest = nil, sellerListings = [])
    @operationRequest = operationRequest
    @sellerListings = sellerListings
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingLookupResponse
class SellerListingLookupResponse
  @@schema_type = "SellerListingLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["sellerListings", ["SellerListings[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListings")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :sellerListings

  def initialize(operationRequest = nil, sellerListings = [])
    @operationRequest = operationRequest
    @sellerListings = sellerListings
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}BrowseNodeLookupResponse
class BrowseNodeLookupResponse
  @@schema_type = "BrowseNodeLookupResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["browseNodes", ["BrowseNodes[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodes")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :browseNodes

  def initialize(operationRequest = nil, browseNodes = [])
    @operationRequest = operationRequest
    @browseNodes = browseNodes
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}MultiOperationResponse
class MultiOperationResponse
  @@schema_type = "MultiOperationResponse"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["operationRequest", ["OperationRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationRequest")]],
    ["helpResponse", ["HelpResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HelpResponse")]],
    ["itemSearchResponse", ["ItemSearchResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemSearchResponse")]],
    ["itemLookupResponse", ["ItemLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemLookupResponse")]],
    ["listSearchResponse", ["ListSearchResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListSearchResponse")]],
    ["listLookupResponse", ["ListLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListLookupResponse")]],
    ["customerContentSearchResponse", ["CustomerContentSearchResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentSearchResponse")]],
    ["customerContentLookupResponse", ["CustomerContentLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentLookupResponse")]],
    ["similarityLookupResponse", ["SimilarityLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityLookupResponse")]],
    ["sellerLookupResponse", ["SellerLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLookupResponse")]],
    ["cartGetResponse", ["CartGetResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartGetResponse")]],
    ["cartAddResponse", ["CartAddResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartAddResponse")]],
    ["cartCreateResponse", ["CartCreateResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartCreateResponse")]],
    ["cartModifyResponse", ["CartModifyResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartModifyResponse")]],
    ["cartClearResponse", ["CartClearResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartClearResponse")]],
    ["transactionLookupResponse", ["TransactionLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionLookupResponse")]],
    ["sellerListingSearchResponse", ["SellerListingSearchResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingSearchResponse")]],
    ["sellerListingLookupResponse", ["SellerListingLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingLookupResponse")]],
    ["browseNodeLookupResponse", ["BrowseNodeLookupResponse", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeLookupResponse")]]
  ]

  attr_accessor :operationRequest
  attr_accessor :helpResponse
  attr_accessor :itemSearchResponse
  attr_accessor :itemLookupResponse
  attr_accessor :listSearchResponse
  attr_accessor :listLookupResponse
  attr_accessor :customerContentSearchResponse
  attr_accessor :customerContentLookupResponse
  attr_accessor :similarityLookupResponse
  attr_accessor :sellerLookupResponse
  attr_accessor :cartGetResponse
  attr_accessor :cartAddResponse
  attr_accessor :cartCreateResponse
  attr_accessor :cartModifyResponse
  attr_accessor :cartClearResponse
  attr_accessor :transactionLookupResponse
  attr_accessor :sellerListingSearchResponse
  attr_accessor :sellerListingLookupResponse
  attr_accessor :browseNodeLookupResponse

  def initialize(operationRequest = nil, helpResponse = nil, itemSearchResponse = nil, itemLookupResponse = nil, listSearchResponse = nil, listLookupResponse = nil, customerContentSearchResponse = nil, customerContentLookupResponse = nil, similarityLookupResponse = nil, sellerLookupResponse = nil, cartGetResponse = nil, cartAddResponse = nil, cartCreateResponse = nil, cartModifyResponse = nil, cartClearResponse = nil, transactionLookupResponse = nil, sellerListingSearchResponse = nil, sellerListingLookupResponse = nil, browseNodeLookupResponse = nil)
    @operationRequest = operationRequest
    @helpResponse = helpResponse
    @itemSearchResponse = itemSearchResponse
    @itemLookupResponse = itemLookupResponse
    @listSearchResponse = listSearchResponse
    @listLookupResponse = listLookupResponse
    @customerContentSearchResponse = customerContentSearchResponse
    @customerContentLookupResponse = customerContentLookupResponse
    @similarityLookupResponse = similarityLookupResponse
    @sellerLookupResponse = sellerLookupResponse
    @cartGetResponse = cartGetResponse
    @cartAddResponse = cartAddResponse
    @cartCreateResponse = cartCreateResponse
    @cartModifyResponse = cartModifyResponse
    @cartClearResponse = cartClearResponse
    @transactionLookupResponse = transactionLookupResponse
    @sellerListingSearchResponse = sellerListingSearchResponse
    @sellerListingLookupResponse = sellerListingLookupResponse
    @browseNodeLookupResponse = browseNodeLookupResponse
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OperationRequest
class OperationRequest
  @@schema_type = "OperationRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["hTTPHeaders", ["HTTPHeaders", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HTTPHeaders")]],
    ["requestId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RequestId")]],
    ["arguments", ["Arguments", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Arguments")]],
    ["errors", ["Errors", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Errors")]],
    ["requestProcessingTime", ["SOAP::SOAPFloat", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RequestProcessingTime")]]
  ]

  attr_accessor :hTTPHeaders
  attr_accessor :requestId
  attr_accessor :arguments
  attr_accessor :errors
  attr_accessor :requestProcessingTime

  def initialize(hTTPHeaders = nil, requestId = nil, arguments = nil, errors = nil, requestProcessingTime = nil)
    @hTTPHeaders = hTTPHeaders
    @requestId = requestId
    @arguments = arguments
    @errors = errors
    @requestProcessingTime = requestProcessingTime
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Request
class Request
  @@schema_type = "Request"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["isValid", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsValid")]],
    ["helpRequest", ["HelpRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HelpRequest")]],
    ["browseNodeLookupRequest", ["BrowseNodeLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeLookupRequest")]],
    ["itemSearchRequest", ["ItemSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemSearchRequest")]],
    ["itemLookupRequest", ["ItemLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemLookupRequest")]],
    ["listSearchRequest", ["ListSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListSearchRequest")]],
    ["listLookupRequest", ["ListLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListLookupRequest")]],
    ["customerContentSearchRequest", ["CustomerContentSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentSearchRequest")]],
    ["customerContentLookupRequest", ["CustomerContentLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerContentLookupRequest")]],
    ["similarityLookupRequest", ["SimilarityLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityLookupRequest")]],
    ["cartGetRequest", ["CartGetRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartGetRequest")]],
    ["cartAddRequest", ["CartAddRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartAddRequest")]],
    ["cartCreateRequest", ["CartCreateRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartCreateRequest")]],
    ["cartModifyRequest", ["CartModifyRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartModifyRequest")]],
    ["cartClearRequest", ["CartClearRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartClearRequest")]],
    ["transactionLookupRequest", ["TransactionLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionLookupRequest")]],
    ["sellerListingSearchRequest", ["SellerListingSearchRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingSearchRequest")]],
    ["sellerListingLookupRequest", ["SellerListingLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListingLookupRequest")]],
    ["sellerLookupRequest", ["SellerLookupRequest", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLookupRequest")]],
    ["errors", ["Errors", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Errors")]]
  ]

  attr_accessor :isValid
  attr_accessor :helpRequest
  attr_accessor :browseNodeLookupRequest
  attr_accessor :itemSearchRequest
  attr_accessor :itemLookupRequest
  attr_accessor :listSearchRequest
  attr_accessor :listLookupRequest
  attr_accessor :customerContentSearchRequest
  attr_accessor :customerContentLookupRequest
  attr_accessor :similarityLookupRequest
  attr_accessor :cartGetRequest
  attr_accessor :cartAddRequest
  attr_accessor :cartCreateRequest
  attr_accessor :cartModifyRequest
  attr_accessor :cartClearRequest
  attr_accessor :transactionLookupRequest
  attr_accessor :sellerListingSearchRequest
  attr_accessor :sellerListingLookupRequest
  attr_accessor :sellerLookupRequest
  attr_accessor :errors

  def initialize(isValid = nil, helpRequest = nil, browseNodeLookupRequest = nil, itemSearchRequest = nil, itemLookupRequest = nil, listSearchRequest = nil, listLookupRequest = nil, customerContentSearchRequest = nil, customerContentLookupRequest = nil, similarityLookupRequest = nil, cartGetRequest = nil, cartAddRequest = nil, cartCreateRequest = nil, cartModifyRequest = nil, cartClearRequest = nil, transactionLookupRequest = nil, sellerListingSearchRequest = nil, sellerListingLookupRequest = nil, sellerLookupRequest = nil, errors = nil)
    @isValid = isValid
    @helpRequest = helpRequest
    @browseNodeLookupRequest = browseNodeLookupRequest
    @itemSearchRequest = itemSearchRequest
    @itemLookupRequest = itemLookupRequest
    @listSearchRequest = listSearchRequest
    @listLookupRequest = listLookupRequest
    @customerContentSearchRequest = customerContentSearchRequest
    @customerContentLookupRequest = customerContentLookupRequest
    @similarityLookupRequest = similarityLookupRequest
    @cartGetRequest = cartGetRequest
    @cartAddRequest = cartAddRequest
    @cartCreateRequest = cartCreateRequest
    @cartModifyRequest = cartModifyRequest
    @cartClearRequest = cartClearRequest
    @transactionLookupRequest = transactionLookupRequest
    @sellerListingSearchRequest = sellerListingSearchRequest
    @sellerListingLookupRequest = sellerListingLookupRequest
    @sellerLookupRequest = sellerLookupRequest
    @errors = errors
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Arguments
class Arguments < ::Array
  @@schema_element = [
    ["Argument", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Argument")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}HTTPHeaders
class HTTPHeaders < ::Array
  @@schema_element = [
    ["Header", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Header")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Errors
class Errors < ::Array
  @@schema_element = [
    ["Error", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Error")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Information
class Information
  @@schema_type = "Information"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["operationInformation", ["OperationInformation[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OperationInformation")]],
    ["responseGroupInformation", ["ResponseGroupInformation[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroupInformation")]]
  ]

  attr_accessor :request
  attr_accessor :operationInformation
  attr_accessor :responseGroupInformation

  def initialize(request = nil, operationInformation = [], responseGroupInformation = [])
    @request = request
    @operationInformation = operationInformation
    @responseGroupInformation = responseGroupInformation
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Items
class Items
  @@schema_type = "Items"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["correctedQuery", ["CorrectedQuery", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CorrectedQuery")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["searchResultsMap", ["SearchResultsMap", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchResultsMap")]],
    ["item", ["Item[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Item")]],
    ["searchBinSets", ["SearchBinSets", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchBinSets")]]
  ]

  attr_accessor :request
  attr_accessor :correctedQuery
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :searchResultsMap
  attr_accessor :item
  attr_accessor :searchBinSets

  def initialize(request = nil, correctedQuery = nil, totalResults = nil, totalPages = nil, searchResultsMap = nil, item = [], searchBinSets = nil)
    @request = request
    @correctedQuery = correctedQuery
    @totalResults = totalResults
    @totalPages = totalPages
    @searchResultsMap = searchResultsMap
    @item = item
    @searchBinSets = searchBinSets
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CorrectedQuery
class CorrectedQuery
  @@schema_type = "CorrectedQuery"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["keywords", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Keywords")]],
    ["message", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Message")]]
  ]

  attr_accessor :keywords
  attr_accessor :message

  def initialize(keywords = nil, message = nil)
    @keywords = keywords
    @message = message
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Lists
class Lists
  @@schema_type = "Lists"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["list", ["List[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "List")]]
  ]

  attr_accessor :request
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :list

  def initialize(request = nil, totalResults = nil, totalPages = nil, list = [])
    @request = request
    @totalResults = totalResults
    @totalPages = totalPages
    @list = list
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Customers
class Customers
  @@schema_type = "Customers"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["customer", ["Customer[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Customer")]]
  ]

  attr_accessor :request
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :customer

  def initialize(request = nil, totalResults = nil, totalPages = nil, customer = [])
    @request = request
    @totalResults = totalResults
    @totalPages = totalPages
    @customer = customer
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Cart
class Cart
  @@schema_type = "Cart"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["cartId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartId")]],
    ["hMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HMAC")]],
    ["uRLEncodedHMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "URLEncodedHMAC")]],
    ["purchaseURL", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PurchaseURL")]],
    ["subTotal", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubTotal")]],
    ["cartItems", ["CartItems", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartItems")]],
    ["savedForLaterItems", ["SavedForLaterItems", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SavedForLaterItems")]],
    ["similarProducts", ["SimilarProducts", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarProducts")]],
    ["topSellers", ["TopSellers", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TopSellers")]],
    ["newReleases", ["NewReleases", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NewReleases")]],
    ["similarViewedProducts", ["SimilarViewedProducts", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarViewedProducts")]],
    ["otherCategoriesSimilarProducts", ["OtherCategoriesSimilarProducts", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OtherCategoriesSimilarProducts")]]
  ]

  attr_accessor :request
  attr_accessor :cartId
  attr_accessor :hMAC
  attr_accessor :uRLEncodedHMAC
  attr_accessor :purchaseURL
  attr_accessor :subTotal
  attr_accessor :cartItems
  attr_accessor :savedForLaterItems
  attr_accessor :similarProducts
  attr_accessor :topSellers
  attr_accessor :newReleases
  attr_accessor :similarViewedProducts
  attr_accessor :otherCategoriesSimilarProducts

  def initialize(request = nil, cartId = nil, hMAC = nil, uRLEncodedHMAC = nil, purchaseURL = nil, subTotal = nil, cartItems = nil, savedForLaterItems = nil, similarProducts = nil, topSellers = nil, newReleases = nil, similarViewedProducts = nil, otherCategoriesSimilarProducts = nil)
    @request = request
    @cartId = cartId
    @hMAC = hMAC
    @uRLEncodedHMAC = uRLEncodedHMAC
    @purchaseURL = purchaseURL
    @subTotal = subTotal
    @cartItems = cartItems
    @savedForLaterItems = savedForLaterItems
    @similarProducts = similarProducts
    @topSellers = topSellers
    @newReleases = newReleases
    @similarViewedProducts = similarViewedProducts
    @otherCategoriesSimilarProducts = otherCategoriesSimilarProducts
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Transactions
class Transactions
  @@schema_type = "Transactions"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["transaction", ["Transaction[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Transaction")]]
  ]

  attr_accessor :request
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :transaction

  def initialize(request = nil, totalResults = nil, totalPages = nil, transaction = [])
    @request = request
    @totalResults = totalResults
    @totalPages = totalPages
    @transaction = transaction
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Sellers
class Sellers
  @@schema_type = "Sellers"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["seller", ["Seller[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Seller")]]
  ]

  attr_accessor :request
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :seller

  def initialize(request = nil, totalResults = nil, totalPages = nil, seller = [])
    @request = request
    @totalResults = totalResults
    @totalPages = totalPages
    @seller = seller
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListings
class SellerListings
  @@schema_type = "SellerListings"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["totalResults", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalResults")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["sellerListing", ["SellerListing[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerListing")]]
  ]

  attr_accessor :request
  attr_accessor :totalResults
  attr_accessor :totalPages
  attr_accessor :sellerListing

  def initialize(request = nil, totalResults = nil, totalPages = nil, sellerListing = [])
    @request = request
    @totalResults = totalResults
    @totalPages = totalPages
    @sellerListing = sellerListing
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OperationInformation
class OperationInformation
  @@schema_type = "OperationInformation"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["description", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Description")]],
    ["requiredParameters", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RequiredParameters")]],
    ["availableParameters", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AvailableParameters")]],
    ["defaultResponseGroups", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DefaultResponseGroups")]],
    ["availableResponseGroups", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AvailableResponseGroups")]]
  ]

  attr_accessor :name
  attr_accessor :description
  attr_accessor :requiredParameters
  attr_accessor :availableParameters
  attr_accessor :defaultResponseGroups
  attr_accessor :availableResponseGroups

  def initialize(name = nil, description = nil, requiredParameters = nil, availableParameters = nil, defaultResponseGroups = nil, availableResponseGroups = nil)
    @name = name
    @description = description
    @requiredParameters = requiredParameters
    @availableParameters = availableParameters
    @defaultResponseGroups = defaultResponseGroups
    @availableResponseGroups = availableResponseGroups
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ResponseGroupInformation
class ResponseGroupInformation
  @@schema_type = "ResponseGroupInformation"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["creationDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CreationDate")]],
    ["validOperations", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ValidOperations")]],
    ["elements", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Elements")]]
  ]

  attr_accessor :name
  attr_accessor :creationDate
  attr_accessor :validOperations
  attr_accessor :elements

  def initialize(name = nil, creationDate = nil, validOperations = nil, elements = nil)
    @name = name
    @creationDate = creationDate
    @validOperations = validOperations
    @elements = elements
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}List
class List
  @@schema_type = "List"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["listId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListId")]],
    ["listURL", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListURL")]],
    ["registryNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RegistryNumber")]],
    ["listName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListName")]],
    ["listType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListType")]],
    ["totalItems", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalItems")]],
    ["totalPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPages")]],
    ["dateCreated", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DateCreated")]],
    ["occasionDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OccasionDate")]],
    ["customerName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerName")]],
    ["partnerName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PartnerName")]],
    ["additionalName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AdditionalName")]],
    ["comment", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Comment")]],
    ["image", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Image")]],
    ["averageRating", ["SOAP::SOAPDecimal", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AverageRating")]],
    ["totalVotes", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVotes")]],
    ["totalTimesRead", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalTimesRead")]],
    ["listItem", ["ListItem[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListItem")]]
  ]

  attr_accessor :listId
  attr_accessor :listURL
  attr_accessor :registryNumber
  attr_accessor :listName
  attr_accessor :listType
  attr_accessor :totalItems
  attr_accessor :totalPages
  attr_accessor :dateCreated
  attr_accessor :occasionDate
  attr_accessor :customerName
  attr_accessor :partnerName
  attr_accessor :additionalName
  attr_accessor :comment
  attr_accessor :image
  attr_accessor :averageRating
  attr_accessor :totalVotes
  attr_accessor :totalTimesRead
  attr_accessor :listItem

  def initialize(listId = nil, listURL = nil, registryNumber = nil, listName = nil, listType = nil, totalItems = nil, totalPages = nil, dateCreated = nil, occasionDate = nil, customerName = nil, partnerName = nil, additionalName = nil, comment = nil, image = nil, averageRating = nil, totalVotes = nil, totalTimesRead = nil, listItem = [])
    @listId = listId
    @listURL = listURL
    @registryNumber = registryNumber
    @listName = listName
    @listType = listType
    @totalItems = totalItems
    @totalPages = totalPages
    @dateCreated = dateCreated
    @occasionDate = occasionDate
    @customerName = customerName
    @partnerName = partnerName
    @additionalName = additionalName
    @comment = comment
    @image = image
    @averageRating = averageRating
    @totalVotes = totalVotes
    @totalTimesRead = totalTimesRead
    @listItem = listItem
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListItem
class ListItem
  @@schema_type = "ListItem"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["listItemId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListItemId")]],
    ["dateAdded", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DateAdded")]],
    ["comment", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Comment")]],
    ["quantityDesired", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "QuantityDesired")]],
    ["quantityReceived", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "QuantityReceived")]],
    ["item", ["Item", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Item")]]
  ]

  attr_accessor :listItemId
  attr_accessor :dateAdded
  attr_accessor :comment
  attr_accessor :quantityDesired
  attr_accessor :quantityReceived
  attr_accessor :item

  def initialize(listItemId = nil, dateAdded = nil, comment = nil, quantityDesired = nil, quantityReceived = nil, item = nil)
    @listItemId = listItemId
    @dateAdded = dateAdded
    @comment = comment
    @quantityDesired = quantityDesired
    @quantityReceived = quantityReceived
    @item = item
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Customer
class Customer
  @@schema_type = "Customer"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["customerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerId")]],
    ["nickname", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Nickname")]],
    ["birthday", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Birthday")]],
    ["wishListId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WishListId")]],
    ["location", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Location")]],
    ["customerReviews", ["CustomerReviews[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerReviews")]]
  ]

  attr_accessor :customerId
  attr_accessor :nickname
  attr_accessor :birthday
  attr_accessor :wishListId
  attr_accessor :location
  attr_accessor :customerReviews

  def initialize(customerId = nil, nickname = nil, birthday = nil, wishListId = nil, location = nil, customerReviews = [])
    @customerId = customerId
    @nickname = nickname
    @birthday = birthday
    @wishListId = wishListId
    @location = location
    @customerReviews = customerReviews
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SearchResultsMap
class SearchResultsMap < ::Array
  @@schema_element = [
    ["SearchIndex", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchIndex")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Item
class Item
  @@schema_type = "Item"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["aSIN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ASIN")]],
    ["errors", ["Errors", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Errors")]],
    ["detailPageURL", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DetailPageURL")]],
    ["salesRank", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SalesRank")]],
    ["smallImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SmallImage")]],
    ["mediumImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MediumImage")]],
    ["largeImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LargeImage")]],
    ["imageSets", ["[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ImageSets")]],
    ["itemAttributes", ["ItemAttributes", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemAttributes")]],
    ["merchantItemAttributes", ["MerchantItemAttributes", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantItemAttributes")]],
    ["subjects", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Subjects")]],
    ["offerSummary", ["OfferSummary", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferSummary")]],
    ["offers", ["Offers", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Offers")]],
    ["variationSummary", ["VariationSummary", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationSummary")]],
    ["variations", ["Variations", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Variations")]],
    ["customerReviews", ["CustomerReviews", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerReviews")]],
    ["editorialReviews", ["EditorialReviews", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EditorialReviews")]],
    ["similarProducts", ["SimilarProducts", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarProducts")]],
    ["accessories", ["Accessories", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Accessories")]],
    ["tracks", ["Tracks", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Tracks")]],
    ["browseNodes", ["BrowseNodes", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodes")]],
    ["listmaniaLists", ["ListmaniaLists", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListmaniaLists")]],
    ["searchInside", ["SearchInside", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchInside")]]
  ]

  attr_accessor :aSIN
  attr_accessor :errors
  attr_accessor :detailPageURL
  attr_accessor :salesRank
  attr_accessor :smallImage
  attr_accessor :mediumImage
  attr_accessor :largeImage
  attr_accessor :imageSets
  attr_accessor :itemAttributes
  attr_accessor :merchantItemAttributes
  attr_accessor :subjects
  attr_accessor :offerSummary
  attr_accessor :offers
  attr_accessor :variationSummary
  attr_accessor :variations
  attr_accessor :customerReviews
  attr_accessor :editorialReviews
  attr_accessor :similarProducts
  attr_accessor :accessories
  attr_accessor :tracks
  attr_accessor :browseNodes
  attr_accessor :listmaniaLists
  attr_accessor :searchInside

  def initialize(aSIN = nil, errors = nil, detailPageURL = nil, salesRank = nil, smallImage = nil, mediumImage = nil, largeImage = nil, imageSets = [], itemAttributes = nil, merchantItemAttributes = nil, subjects = nil, offerSummary = nil, offers = nil, variationSummary = nil, variations = nil, customerReviews = nil, editorialReviews = nil, similarProducts = nil, accessories = nil, tracks = nil, browseNodes = nil, listmaniaLists = nil, searchInside = nil)
    @aSIN = aSIN
    @errors = errors
    @detailPageURL = detailPageURL
    @salesRank = salesRank
    @smallImage = smallImage
    @mediumImage = mediumImage
    @largeImage = largeImage
    @imageSets = imageSets
    @itemAttributes = itemAttributes
    @merchantItemAttributes = merchantItemAttributes
    @subjects = subjects
    @offerSummary = offerSummary
    @offers = offers
    @variationSummary = variationSummary
    @variations = variations
    @customerReviews = customerReviews
    @editorialReviews = editorialReviews
    @similarProducts = similarProducts
    @accessories = accessories
    @tracks = tracks
    @browseNodes = browseNodes
    @listmaniaLists = listmaniaLists
    @searchInside = searchInside
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OfferSummary
class OfferSummary
  @@schema_type = "OfferSummary"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["lowestNewPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestNewPrice")]],
    ["lowestUsedPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestUsedPrice")]],
    ["lowestCollectiblePrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestCollectiblePrice")]],
    ["lowestRefurbishedPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestRefurbishedPrice")]],
    ["totalNew", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalNew")]],
    ["totalUsed", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalUsed")]],
    ["totalCollectible", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalCollectible")]],
    ["totalRefurbished", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalRefurbished")]]
  ]

  attr_accessor :lowestNewPrice
  attr_accessor :lowestUsedPrice
  attr_accessor :lowestCollectiblePrice
  attr_accessor :lowestRefurbishedPrice
  attr_accessor :totalNew
  attr_accessor :totalUsed
  attr_accessor :totalCollectible
  attr_accessor :totalRefurbished

  def initialize(lowestNewPrice = nil, lowestUsedPrice = nil, lowestCollectiblePrice = nil, lowestRefurbishedPrice = nil, totalNew = nil, totalUsed = nil, totalCollectible = nil, totalRefurbished = nil)
    @lowestNewPrice = lowestNewPrice
    @lowestUsedPrice = lowestUsedPrice
    @lowestCollectiblePrice = lowestCollectiblePrice
    @lowestRefurbishedPrice = lowestRefurbishedPrice
    @totalNew = totalNew
    @totalUsed = totalUsed
    @totalCollectible = totalCollectible
    @totalRefurbished = totalRefurbished
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Offers
class Offers
  @@schema_type = "Offers"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["totalOffers", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalOffers")]],
    ["totalOfferPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalOfferPages")]],
    ["offer", ["Offer[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Offer")]]
  ]

  attr_accessor :totalOffers
  attr_accessor :totalOfferPages
  attr_accessor :offer

  def initialize(totalOffers = nil, totalOfferPages = nil, offer = [])
    @totalOffers = totalOffers
    @totalOfferPages = totalOfferPages
    @offer = offer
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Offer
class Offer
  @@schema_type = "Offer"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["merchant", ["Merchant", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Merchant")]],
    ["seller", ["Seller", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Seller")]],
    ["offerAttributes", ["OfferAttributes", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferAttributes")]],
    ["offerListing", ["OfferListing[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferListing")]]
  ]

  attr_accessor :merchant
  attr_accessor :seller
  attr_accessor :offerAttributes
  attr_accessor :offerListing

  def initialize(merchant = nil, seller = nil, offerAttributes = nil, offerListing = [])
    @merchant = merchant
    @seller = seller
    @offerAttributes = offerAttributes
    @offerListing = offerListing
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OfferAttributes
class OfferAttributes
  @@schema_type = "OfferAttributes"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["subCondition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubCondition")]],
    ["conditionNote", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ConditionNote")]],
    ["willShipExpedited", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WillShipExpedited")]],
    ["willShipInternational", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WillShipInternational")]]
  ]

  attr_accessor :condition
  attr_accessor :subCondition
  attr_accessor :conditionNote
  attr_accessor :willShipExpedited
  attr_accessor :willShipInternational

  def initialize(condition = nil, subCondition = nil, conditionNote = nil, willShipExpedited = nil, willShipInternational = nil)
    @condition = condition
    @subCondition = subCondition
    @conditionNote = conditionNote
    @willShipExpedited = willShipExpedited
    @willShipInternational = willShipInternational
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Merchant
class Merchant
  @@schema_type = "Merchant"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["glancePage", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GlancePage")]],
    ["averageFeedbackRating", ["SOAP::SOAPDecimal", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AverageFeedbackRating")]],
    ["totalFeedback", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFeedback")]],
    ["totalFeedbackPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFeedbackPages")]]
  ]

  attr_accessor :merchantId
  attr_accessor :name
  attr_accessor :glancePage
  attr_accessor :averageFeedbackRating
  attr_accessor :totalFeedback
  attr_accessor :totalFeedbackPages

  def initialize(merchantId = nil, name = nil, glancePage = nil, averageFeedbackRating = nil, totalFeedback = nil, totalFeedbackPages = nil)
    @merchantId = merchantId
    @name = name
    @glancePage = glancePage
    @averageFeedbackRating = averageFeedbackRating
    @totalFeedback = totalFeedback
    @totalFeedbackPages = totalFeedbackPages
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OfferListing
class OfferListing
  @@schema_type = "OfferListing"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["offerListingId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferListingId")]],
    ["exchangeId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ExchangeId")]],
    ["price", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Price")]],
    ["salePrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SalePrice")]],
    ["availability", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Availability")]],
    ["iSPUStoreAddress", ["Address", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUStoreAddress")]],
    ["iSPUStoreHours", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUStoreHours")]],
    ["isEligibleForSuperSaverShipping", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsEligibleForSuperSaverShipping")]]
  ]

  attr_accessor :offerListingId
  attr_accessor :exchangeId
  attr_accessor :price
  attr_accessor :salePrice
  attr_accessor :availability
  attr_accessor :iSPUStoreAddress
  attr_accessor :iSPUStoreHours
  attr_accessor :isEligibleForSuperSaverShipping

  def initialize(offerListingId = nil, exchangeId = nil, price = nil, salePrice = nil, availability = nil, iSPUStoreAddress = nil, iSPUStoreHours = nil, isEligibleForSuperSaverShipping = nil)
    @offerListingId = offerListingId
    @exchangeId = exchangeId
    @price = price
    @salePrice = salePrice
    @availability = availability
    @iSPUStoreAddress = iSPUStoreAddress
    @iSPUStoreHours = iSPUStoreHours
    @isEligibleForSuperSaverShipping = isEligibleForSuperSaverShipping
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}VariationSummary
class VariationSummary
  @@schema_type = "VariationSummary"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["lowestPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestPrice")]],
    ["highestPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HighestPrice")]],
    ["lowestSalePrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LowestSalePrice")]],
    ["highestSalePrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HighestSalePrice")]],
    ["singleMerchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SingleMerchantId")]]
  ]

  attr_accessor :lowestPrice
  attr_accessor :highestPrice
  attr_accessor :lowestSalePrice
  attr_accessor :highestSalePrice
  attr_accessor :singleMerchantId

  def initialize(lowestPrice = nil, highestPrice = nil, lowestSalePrice = nil, highestSalePrice = nil, singleMerchantId = nil)
    @lowestPrice = lowestPrice
    @highestPrice = highestPrice
    @lowestSalePrice = lowestSalePrice
    @highestSalePrice = highestSalePrice
    @singleMerchantId = singleMerchantId
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Variations
class Variations
  @@schema_type = "Variations"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["totalVariations", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVariations")]],
    ["totalVariationPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVariationPages")]],
    ["variationDimensions", ["VariationDimensions", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDimensions")]],
    ["item", ["Item[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Item")]]
  ]

  attr_accessor :totalVariations
  attr_accessor :totalVariationPages
  attr_accessor :variationDimensions
  attr_accessor :item

  def initialize(totalVariations = nil, totalVariationPages = nil, variationDimensions = nil, item = [])
    @totalVariations = totalVariations
    @totalVariationPages = totalVariationPages
    @variationDimensions = variationDimensions
    @item = item
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}VariationDimensions
class VariationDimensions < ::Array
  @@schema_element = [
    ["VariationDimension", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDimension")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}EditorialReviews
class EditorialReviews < ::Array
  @@schema_element = [
    ["EditorialReview", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EditorialReview")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}EditorialReview
class EditorialReview
  @@schema_type = "EditorialReview"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["source", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Source")]],
    ["content", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Content")]]
  ]

  attr_accessor :source
  attr_accessor :content

  def initialize(source = nil, content = nil)
    @source = source
    @content = content
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerReviews
class CustomerReviews
  @@schema_type = "CustomerReviews"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["averageRating", ["SOAP::SOAPDecimal", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AverageRating")]],
    ["totalReviews", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalReviews")]],
    ["totalReviewPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalReviewPages")]],
    ["review", ["Review[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Review")]]
  ]

  attr_accessor :averageRating
  attr_accessor :totalReviews
  attr_accessor :totalReviewPages
  attr_accessor :review

  def initialize(averageRating = nil, totalReviews = nil, totalReviewPages = nil, review = [])
    @averageRating = averageRating
    @totalReviews = totalReviews
    @totalReviewPages = totalReviewPages
    @review = review
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Review
class Review
  @@schema_type = "Review"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["aSIN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ASIN")]],
    ["rating", ["SOAP::SOAPDecimal", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Rating")]],
    ["helpfulVotes", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HelpfulVotes")]],
    ["customerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerId")]],
    ["totalVotes", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVotes")]],
    ["date", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Date")]],
    ["summary", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Summary")]],
    ["content", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Content")]]
  ]

  attr_accessor :aSIN
  attr_accessor :rating
  attr_accessor :helpfulVotes
  attr_accessor :customerId
  attr_accessor :totalVotes
  attr_accessor :date
  attr_accessor :summary
  attr_accessor :content

  def initialize(aSIN = nil, rating = nil, helpfulVotes = nil, customerId = nil, totalVotes = nil, date = nil, summary = nil, content = nil)
    @aSIN = aSIN
    @rating = rating
    @helpfulVotes = helpfulVotes
    @customerId = customerId
    @totalVotes = totalVotes
    @date = date
    @summary = summary
    @content = content
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Tracks
class Tracks < ::Array
  @@schema_element = [
    ["Disc", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Disc")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SimilarProducts
class SimilarProducts < ::Array
  @@schema_element = [
    ["SimilarProduct", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarProduct")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}TopSellers
class TopSellers < ::Array
  @@schema_element = [
    ["TopSeller", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TopSeller")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}NewReleases
class NewReleases < ::Array
  @@schema_element = [
    ["NewRelease", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NewRelease")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SimilarViewedProducts
class SimilarViewedProducts < ::Array
  @@schema_element = [
    ["SimilarViewedProduct", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarViewedProduct")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}OtherCategoriesSimilarProducts
class OtherCategoriesSimilarProducts < ::Array
  @@schema_element = [
    ["OtherCategoriesSimilarProduct", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OtherCategoriesSimilarProduct")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Accessories
class Accessories < ::Array
  @@schema_element = [
    ["Accessory", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Accessory")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}BrowseNodes
class BrowseNodes
  @@schema_type = "BrowseNodes"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["request", ["Request", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Request")]],
    ["browseNode", ["BrowseNode[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNode")]]
  ]

  attr_accessor :request
  attr_accessor :browseNode

  def initialize(request = nil, browseNode = [])
    @request = request
    @browseNode = browseNode
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}BrowseNode
class BrowseNode
  @@schema_type = "BrowseNode"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["browseNodeId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeId")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["children", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Children")]],
    ["ancestors", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Ancestors")]],
    ["topSellers", ["TopSellers", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TopSellers")]],
    ["newReleases", ["NewReleases", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NewReleases")]]
  ]

  attr_accessor :browseNodeId
  attr_accessor :name
  attr_accessor :children
  attr_accessor :ancestors
  attr_accessor :topSellers
  attr_accessor :newReleases

  def initialize(browseNodeId = nil, name = nil, children = nil, ancestors = nil, topSellers = nil, newReleases = nil)
    @browseNodeId = browseNodeId
    @name = name
    @children = children
    @ancestors = ancestors
    @topSellers = topSellers
    @newReleases = newReleases
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListmaniaLists
class ListmaniaLists < ::Array
  @@schema_element = [
    ["ListmaniaList", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListmaniaList")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SearchInside
class SearchInside
  @@schema_type = "SearchInside"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["totalExcerpts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalExcerpts")]],
    ["excerpt", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Excerpt")]]
  ]

  attr_accessor :totalExcerpts
  attr_accessor :excerpt

  def initialize(totalExcerpts = nil, excerpt = nil)
    @totalExcerpts = totalExcerpts
    @excerpt = excerpt
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartItems
class CartItems
  @@schema_type = "CartItems"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["subTotal", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubTotal")]],
    ["cartItem", ["CartItem[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartItem")]]
  ]

  attr_accessor :subTotal
  attr_accessor :cartItem

  def initialize(subTotal = nil, cartItem = [])
    @subTotal = subTotal
    @cartItem = cartItem
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SavedForLaterItems
class SavedForLaterItems
  @@schema_type = "SavedForLaterItems"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["subTotal", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubTotal")]],
    ["savedForLaterItem", ["CartItem[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SavedForLaterItem")]]
  ]

  attr_accessor :subTotal
  attr_accessor :savedForLaterItem

  def initialize(subTotal = nil, savedForLaterItem = [])
    @subTotal = subTotal
    @savedForLaterItem = savedForLaterItem
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Transaction
class Transaction
  @@schema_type = "Transaction"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["transactionId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionId")]],
    ["sellerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["transactionDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionDate")]],
    ["transactionDateEpoch", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionDateEpoch")]],
    ["sellerName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerName")]],
    ["payingCustomerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PayingCustomerId")]],
    ["orderingCustomerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OrderingCustomerId")]],
    ["totals", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Totals")]],
    ["transactionItems", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionItems")]],
    ["shipments", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Shipments")]]
  ]

  attr_accessor :transactionId
  attr_accessor :sellerId
  attr_accessor :condition
  attr_accessor :transactionDate
  attr_accessor :transactionDateEpoch
  attr_accessor :sellerName
  attr_accessor :payingCustomerId
  attr_accessor :orderingCustomerId
  attr_accessor :totals
  attr_accessor :transactionItems
  attr_accessor :shipments

  def initialize(transactionId = nil, sellerId = nil, condition = nil, transactionDate = nil, transactionDateEpoch = nil, sellerName = nil, payingCustomerId = nil, orderingCustomerId = nil, totals = nil, transactionItems = nil, shipments = nil)
    @transactionId = transactionId
    @sellerId = sellerId
    @condition = condition
    @transactionDate = transactionDate
    @transactionDateEpoch = transactionDateEpoch
    @sellerName = sellerName
    @payingCustomerId = payingCustomerId
    @orderingCustomerId = orderingCustomerId
    @totals = totals
    @transactionItems = transactionItems
    @shipments = shipments
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}TransactionItem
class TransactionItem
  @@schema_type = "TransactionItem"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["transactionItemId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionItemId")]],
    ["quantity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Quantity")]],
    ["unitPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "UnitPrice")]],
    ["totalPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPrice")]],
    ["aSIN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ASIN")]],
    ["childTransactionItems", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ChildTransactionItems")]]
  ]

  attr_accessor :transactionItemId
  attr_accessor :quantity
  attr_accessor :unitPrice
  attr_accessor :totalPrice
  attr_accessor :aSIN
  attr_accessor :childTransactionItems

  def initialize(transactionItemId = nil, quantity = nil, unitPrice = nil, totalPrice = nil, aSIN = nil, childTransactionItems = nil)
    @transactionItemId = transactionItemId
    @quantity = quantity
    @unitPrice = unitPrice
    @totalPrice = totalPrice
    @aSIN = aSIN
    @childTransactionItems = childTransactionItems
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Seller
class Seller
  @@schema_type = "Seller"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["sellerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["sellerName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerName")]],
    ["sellerLegalName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerLegalName")]],
    ["nickname", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Nickname")]],
    ["glancePage", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GlancePage")]],
    ["about", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "About")]],
    ["moreAbout", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MoreAbout")]],
    ["location", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Location")]],
    ["averageFeedbackRating", ["SOAP::SOAPDecimal", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AverageFeedbackRating")]],
    ["totalFeedback", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFeedback")]],
    ["totalFeedbackPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFeedbackPages")]],
    ["sellerFeedbackSummary", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerFeedbackSummary")]],
    ["sellerFeedback", ["SellerFeedback", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerFeedback")]]
  ]

  attr_accessor :sellerId
  attr_accessor :sellerName
  attr_accessor :sellerLegalName
  attr_accessor :nickname
  attr_accessor :glancePage
  attr_accessor :about
  attr_accessor :moreAbout
  attr_accessor :location
  attr_accessor :averageFeedbackRating
  attr_accessor :totalFeedback
  attr_accessor :totalFeedbackPages
  attr_accessor :sellerFeedbackSummary
  attr_accessor :sellerFeedback

  def initialize(sellerId = nil, sellerName = nil, sellerLegalName = nil, nickname = nil, glancePage = nil, about = nil, moreAbout = nil, location = nil, averageFeedbackRating = nil, totalFeedback = nil, totalFeedbackPages = nil, sellerFeedbackSummary = nil, sellerFeedback = nil)
    @sellerId = sellerId
    @sellerName = sellerName
    @sellerLegalName = sellerLegalName
    @nickname = nickname
    @glancePage = glancePage
    @about = about
    @moreAbout = moreAbout
    @location = location
    @averageFeedbackRating = averageFeedbackRating
    @totalFeedback = totalFeedback
    @totalFeedbackPages = totalFeedbackPages
    @sellerFeedbackSummary = sellerFeedbackSummary
    @sellerFeedback = sellerFeedback
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerFeedback
class SellerFeedback < ::Array
  @@schema_element = [
    ["Feedback", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Feedback")]]
  ]
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListing
class SellerListing
  @@schema_type = "SellerListing"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["exchangeId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ExchangeId")]],
    ["listingId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListingId")]],
    ["aSIN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ASIN")]],
    ["sKU", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SKU")]],
    ["uPC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "UPC")]],
    ["eAN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EAN")]],
    ["willShipExpedited", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WillShipExpedited")]],
    ["willShipInternational", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WillShipInternational")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]],
    ["price", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Price")]],
    ["startDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StartDate")]],
    ["endDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EndDate")]],
    ["status", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Status")]],
    ["quantity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Quantity")]],
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["subCondition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubCondition")]],
    ["seller", ["Seller", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Seller")]]
  ]

  attr_accessor :exchangeId
  attr_accessor :listingId
  attr_accessor :aSIN
  attr_accessor :sKU
  attr_accessor :uPC
  attr_accessor :eAN
  attr_accessor :willShipExpedited
  attr_accessor :willShipInternational
  attr_accessor :title
  attr_accessor :price
  attr_accessor :startDate
  attr_accessor :endDate
  attr_accessor :status
  attr_accessor :quantity
  attr_accessor :condition
  attr_accessor :subCondition
  attr_accessor :seller

  def initialize(exchangeId = nil, listingId = nil, aSIN = nil, sKU = nil, uPC = nil, eAN = nil, willShipExpedited = nil, willShipInternational = nil, title = nil, price = nil, startDate = nil, endDate = nil, status = nil, quantity = nil, condition = nil, subCondition = nil, seller = nil)
    @exchangeId = exchangeId
    @listingId = listingId
    @aSIN = aSIN
    @sKU = sKU
    @uPC = uPC
    @eAN = eAN
    @willShipExpedited = willShipExpedited
    @willShipInternational = willShipInternational
    @title = title
    @price = price
    @startDate = startDate
    @endDate = endDate
    @status = status
    @quantity = quantity
    @condition = condition
    @subCondition = subCondition
    @seller = seller
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ImageSet
class ImageSet
  @@schema_type = "ImageSet"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_attribute = {
    XSD::QName.new(nil, "Category") => "SOAP::SOAPString"
  }
  @@schema_element = [
    ["swatchImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SwatchImage")]],
    ["smallImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SmallImage")]],
    ["mediumImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MediumImage")]],
    ["largeImage", ["Image", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LargeImage")]]
  ]

  attr_accessor :swatchImage
  attr_accessor :smallImage
  attr_accessor :mediumImage
  attr_accessor :largeImage

  def xmlattr_Category
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Category")]
  end

  def xmlattr_Category=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Category")] = value
  end

  def initialize(swatchImage = nil, smallImage = nil, mediumImage = nil, largeImage = nil)
    @swatchImage = swatchImage
    @smallImage = smallImage
    @mediumImage = mediumImage
    @largeImage = largeImage
    @__xmlattr = {}
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemAttributes
class ItemAttributes
  @@schema_type = "ItemAttributes"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["actor", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Actor")]],
    ["address", ["Address", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Address")]],
    ["amazonMaximumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AmazonMaximumAge")]],
    ["amazonMinimumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AmazonMinimumAge")]],
    ["apertureModes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ApertureModes")]],
    ["artist", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Artist")]],
    ["aspectRatio", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AspectRatio")]],
    ["audienceRating", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AudienceRating")]],
    ["audioFormat", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AudioFormat")]],
    ["author", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Author")]],
    ["backFinding", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BackFinding")]],
    ["bandMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BandMaterialType")]],
    ["batteriesIncluded", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteriesIncluded")]],
    ["batteries", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Batteries")]],
    ["batteryDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteryDescription")]],
    ["batteryType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteryType")]],
    ["bezelMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BezelMaterialType")]],
    ["binding", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Binding")]],
    ["brand", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Brand")]],
    ["calendarType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CalendarType")]],
    ["cameraManualFeatures", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CameraManualFeatures")]],
    ["caseDiameter", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseDiameter")]],
    ["caseMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseMaterialType")]],
    ["caseThickness", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseThickness")]],
    ["caseType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseType")]],
    ["cDRWDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CDRWDescription")]],
    ["chainType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ChainType")]],
    ["claspType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ClaspType")]],
    ["clothingSize", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ClothingSize")]],
    ["color", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Color")]],
    ["compatibility", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Compatibility")]],
    ["computerHardwareType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ComputerHardwareType")]],
    ["computerPlatform", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ComputerPlatform")]],
    ["connectivity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Connectivity")]],
    ["continuousShootingSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ContinuousShootingSpeed")]],
    ["country", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Country")]],
    ["cPUManufacturer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUManufacturer")]],
    ["cPUSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUSpeed")]],
    ["cPUType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUType")]],
    ["creator", ["[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Creator")]],
    ["cuisine", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cuisine")]],
    ["delayBetweenShots", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DelayBetweenShots")]],
    ["department", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Department")]],
    ["deweyDecimalNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeweyDecimalNumber")]],
    ["dialColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DialColor")]],
    ["dialWindowMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DialWindowMaterialType")]],
    ["digitalZoom", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DigitalZoom")]],
    ["director", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Director")]],
    ["displaySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DisplaySize")]],
    ["drumSetPieceQuantity", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DrumSetPieceQuantity")]],
    ["dVDLayers", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDLayers")]],
    ["dVDRWDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDRWDescription")]],
    ["dVDSides", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDSides")]],
    ["eAN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EAN")]],
    ["edition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Edition")]],
    ["eSRBAgeRating", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ESRBAgeRating")]],
    ["externalDisplaySupportDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ExternalDisplaySupportDescription")]],
    ["fabricType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FabricType")]],
    ["faxNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FaxNumber")]],
    ["feature", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Feature")]],
    ["firstIssueLeadTime", ["StringWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FirstIssueLeadTime")]],
    ["floppyDiskDriveDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FloppyDiskDriveDescription")]],
    ["format", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Format")]],
    ["gemType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GemType")]],
    ["graphicsCardInterface", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsCardInterface")]],
    ["graphicsDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsDescription")]],
    ["graphicsMemorySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsMemorySize")]],
    ["guitarAttribute", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarAttribute")]],
    ["guitarBridgeSystem", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarBridgeSystem")]],
    ["guitarPickThickness", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarPickThickness")]],
    ["guitarPickupConfiguration", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarPickupConfiguration")]],
    ["hardDiskCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HardDiskCount")]],
    ["hardDiskSize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HardDiskSize")]],
    ["hasAutoFocus", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasAutoFocus")]],
    ["hasBurstMode", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasBurstMode")]],
    ["hasInCameraEditing", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasInCameraEditing")]],
    ["hasRedEyeReduction", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasRedEyeReduction")]],
    ["hasSelfTimer", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasSelfTimer")]],
    ["hasTripodMount", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasTripodMount")]],
    ["hasVideoOut", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasVideoOut")]],
    ["hasViewfinder", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasViewfinder")]],
    ["hazardousMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HazardousMaterialType")]],
    ["hoursOfOperation", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HoursOfOperation")]],
    ["includedSoftware", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IncludedSoftware")]],
    ["includesMp3Player", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IncludesMp3Player")]],
    ["ingredients", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Ingredients")]],
    ["instrumentKey", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "InstrumentKey")]],
    ["isAdultProduct", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsAdultProduct")]],
    ["isAutographed", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsAutographed")]],
    ["iSBN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISBN")]],
    ["isFragile", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsFragile")]],
    ["isLabCreated", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsLabCreated")]],
    ["isMemorabilia", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsMemorabilia")]],
    ["iSOEquivalent", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISOEquivalent")]],
    ["issuesPerYear", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IssuesPerYear")]],
    ["itemDimensions", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemDimensions")]],
    ["keyboardDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "KeyboardDescription")]],
    ["label", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Label")]],
    ["languages", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Languages")]],
    ["legalDisclaimer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LegalDisclaimer")]],
    ["lineVoltage", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LineVoltage")]],
    ["listPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListPrice")]],
    ["macroFocusRange", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MacroFocusRange")]],
    ["magazineType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MagazineType")]],
    ["malletHardness", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MalletHardness")]],
    ["manufacturer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Manufacturer")]],
    ["manufacturerLaborWarrantyDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerLaborWarrantyDescription")]],
    ["manufacturerMaximumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerMaximumAge")]],
    ["manufacturerMinimumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerMinimumAge")]],
    ["manufacturerPartsWarrantyDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerPartsWarrantyDescription")]],
    ["materialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaterialType")]],
    ["maximumAperture", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumAperture")]],
    ["maximumColorDepth", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumColorDepth")]],
    ["maximumFocalLength", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumFocalLength")]],
    ["maximumHighResolutionImages", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumHighResolutionImages")]],
    ["maximumHorizontalResolution", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumHorizontalResolution")]],
    ["maximumLowResolutionImages", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumLowResolutionImages")]],
    ["maximumResolution", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumResolution")]],
    ["maximumShutterSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumShutterSpeed")]],
    ["maximumVerticalResolution", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumVerticalResolution")]],
    ["maximumWeightRecommendation", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumWeightRecommendation")]],
    ["memorySlotsAvailable", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MemorySlotsAvailable")]],
    ["metalStamp", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MetalStamp")]],
    ["metalType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MetalType")]],
    ["miniMovieDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MiniMovieDescription")]],
    ["minimumFocalLength", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MinimumFocalLength")]],
    ["minimumShutterSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MinimumShutterSpeed")]],
    ["model", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Model")]],
    ["modelYear", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ModelYear")]],
    ["modemDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ModemDescription")]],
    ["monitorSize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MonitorSize")]],
    ["monitorViewableDiagonalSize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MonitorViewableDiagonalSize")]],
    ["mouseDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MouseDescription")]],
    ["mPN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MPN")]],
    ["musicalStyle", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MusicalStyle")]],
    ["nativeResolution", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NativeResolution")]],
    ["neighborhood", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Neighborhood")]],
    ["networkInterfaceDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NetworkInterfaceDescription")]],
    ["notebookDisplayTechnology", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NotebookDisplayTechnology")]],
    ["notebookPointingDeviceDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NotebookPointingDeviceDescription")]],
    ["numberOfDiscs", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfDiscs")]],
    ["numberOfIssues", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfIssues")]],
    ["numberOfItems", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfItems")]],
    ["numberOfKeys", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfKeys")]],
    ["numberOfPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfPages")]],
    ["numberOfPearls", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfPearls")]],
    ["numberOfRapidFireShots", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfRapidFireShots")]],
    ["numberOfStones", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfStones")]],
    ["numberOfStrings", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfStrings")]],
    ["numberOfTracks", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfTracks")]],
    ["opticalZoom", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OpticalZoom")]],
    ["outputWattage", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OutputWattage")]],
    ["packageDimensions", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PackageDimensions")]],
    ["pearlLustre", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlLustre")]],
    ["pearlMinimumColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlMinimumColor")]],
    ["pearlShape", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlShape")]],
    ["pearlStringingMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlStringingMethod")]],
    ["pearlSurfaceBlemishes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlSurfaceBlemishes")]],
    ["pearlType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlType")]],
    ["pearlUniformity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlUniformity")]],
    ["phoneNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PhoneNumber")]],
    ["photoFlashType", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PhotoFlashType")]],
    ["pictureFormat", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PictureFormat")]],
    ["platform", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Platform")]],
    ["priceRating", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PriceRating")]],
    ["processorCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProcessorCount")]],
    ["productGroup", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProductGroup")]],
    ["promotionalTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PromotionalTag")]],
    ["publicationDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PublicationDate")]],
    ["publisher", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Publisher")]],
    ["readingLevel", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReadingLevel")]],
    ["recorderTrackCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RecorderTrackCount")]],
    ["regionCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RegionCode")]],
    ["regionOfOrigin", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RegionOfOrigin")]],
    ["releaseDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReleaseDate")]],
    ["removableMemory", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RemovableMemory")]],
    ["resolutionModes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResolutionModes")]],
    ["ringSize", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RingSize")]],
    ["runningTime", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RunningTime")]],
    ["secondaryCacheSize", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SecondaryCacheSize")]],
    ["settingType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SettingType")]],
    ["size", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Size")]],
    ["sizePerPearl", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SizePerPearl")]],
    ["skillLevel", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SkillLevel")]],
    ["sKU", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SKU")]],
    ["soundCardDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SoundCardDescription")]],
    ["speakerCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpeakerCount")]],
    ["speakerDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpeakerDescription")]],
    ["specialFeatures", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpecialFeatures")]],
    ["stoneClarity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneClarity")]],
    ["stoneColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneColor")]],
    ["stoneCut", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneCut")]],
    ["stoneShape", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneShape")]],
    ["stoneWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneWeight")]],
    ["studio", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Studio")]],
    ["subscriptionLength", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionLength")]],
    ["supportedImageType", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SupportedImageType")]],
    ["systemBusSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemBusSpeed")]],
    ["systemMemorySizeMax", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemorySizeMax")]],
    ["systemMemorySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemorySize")]],
    ["systemMemoryType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemoryType")]],
    ["theatricalReleaseDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TheatricalReleaseDate")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]],
    ["totalDiamondWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalDiamondWeight")]],
    ["totalExternalBaysFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalExternalBaysFree")]],
    ["totalFirewirePorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFirewirePorts")]],
    ["totalGemWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalGemWeight")]],
    ["totalInternalBaysFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalInternalBaysFree")]],
    ["totalMetalWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalMetalWeight")]],
    ["totalNTSCPALPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalNTSCPALPorts")]],
    ["totalParallelPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalParallelPorts")]],
    ["totalPCCardSlots", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPCCardSlots")]],
    ["totalPCISlotsFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPCISlotsFree")]],
    ["totalSerialPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalSerialPorts")]],
    ["totalSVideoOutPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalSVideoOutPorts")]],
    ["totalUSB2Ports", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalUSB2Ports")]],
    ["totalUSBPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalUSBPorts")]],
    ["totalVGAOutPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVGAOutPorts")]],
    ["uPC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "UPC")]],
    ["variationDenomination", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDenomination")]],
    ["variationDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDescription")]],
    ["warranty", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Warranty")]],
    ["watchMovementType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WatchMovementType")]],
    ["waterResistanceDepth", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WaterResistanceDepth")]],
    ["wirelessMicrophoneFrequency", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WirelessMicrophoneFrequency")]]
  ]

  attr_accessor :actor
  attr_accessor :address
  attr_accessor :amazonMaximumAge
  attr_accessor :amazonMinimumAge
  attr_accessor :apertureModes
  attr_accessor :artist
  attr_accessor :aspectRatio
  attr_accessor :audienceRating
  attr_accessor :audioFormat
  attr_accessor :author
  attr_accessor :backFinding
  attr_accessor :bandMaterialType
  attr_accessor :batteriesIncluded
  attr_accessor :batteries
  attr_accessor :batteryDescription
  attr_accessor :batteryType
  attr_accessor :bezelMaterialType
  attr_accessor :binding
  attr_accessor :brand
  attr_accessor :calendarType
  attr_accessor :cameraManualFeatures
  attr_accessor :caseDiameter
  attr_accessor :caseMaterialType
  attr_accessor :caseThickness
  attr_accessor :caseType
  attr_accessor :cDRWDescription
  attr_accessor :chainType
  attr_accessor :claspType
  attr_accessor :clothingSize
  attr_accessor :color
  attr_accessor :compatibility
  attr_accessor :computerHardwareType
  attr_accessor :computerPlatform
  attr_accessor :connectivity
  attr_accessor :continuousShootingSpeed
  attr_accessor :country
  attr_accessor :cPUManufacturer
  attr_accessor :cPUSpeed
  attr_accessor :cPUType
  attr_accessor :creator
  attr_accessor :cuisine
  attr_accessor :delayBetweenShots
  attr_accessor :department
  attr_accessor :deweyDecimalNumber
  attr_accessor :dialColor
  attr_accessor :dialWindowMaterialType
  attr_accessor :digitalZoom
  attr_accessor :director
  attr_accessor :displaySize
  attr_accessor :drumSetPieceQuantity
  attr_accessor :dVDLayers
  attr_accessor :dVDRWDescription
  attr_accessor :dVDSides
  attr_accessor :eAN
  attr_accessor :edition
  attr_accessor :eSRBAgeRating
  attr_accessor :externalDisplaySupportDescription
  attr_accessor :fabricType
  attr_accessor :faxNumber
  attr_accessor :feature
  attr_accessor :firstIssueLeadTime
  attr_accessor :floppyDiskDriveDescription
  attr_accessor :format
  attr_accessor :gemType
  attr_accessor :graphicsCardInterface
  attr_accessor :graphicsDescription
  attr_accessor :graphicsMemorySize
  attr_accessor :guitarAttribute
  attr_accessor :guitarBridgeSystem
  attr_accessor :guitarPickThickness
  attr_accessor :guitarPickupConfiguration
  attr_accessor :hardDiskCount
  attr_accessor :hardDiskSize
  attr_accessor :hasAutoFocus
  attr_accessor :hasBurstMode
  attr_accessor :hasInCameraEditing
  attr_accessor :hasRedEyeReduction
  attr_accessor :hasSelfTimer
  attr_accessor :hasTripodMount
  attr_accessor :hasVideoOut
  attr_accessor :hasViewfinder
  attr_accessor :hazardousMaterialType
  attr_accessor :hoursOfOperation
  attr_accessor :includedSoftware
  attr_accessor :includesMp3Player
  attr_accessor :ingredients
  attr_accessor :instrumentKey
  attr_accessor :isAdultProduct
  attr_accessor :isAutographed
  attr_accessor :iSBN
  attr_accessor :isFragile
  attr_accessor :isLabCreated
  attr_accessor :isMemorabilia
  attr_accessor :iSOEquivalent
  attr_accessor :issuesPerYear
  attr_accessor :itemDimensions
  attr_accessor :keyboardDescription
  attr_accessor :label
  attr_accessor :languages
  attr_accessor :legalDisclaimer
  attr_accessor :lineVoltage
  attr_accessor :listPrice
  attr_accessor :macroFocusRange
  attr_accessor :magazineType
  attr_accessor :malletHardness
  attr_accessor :manufacturer
  attr_accessor :manufacturerLaborWarrantyDescription
  attr_accessor :manufacturerMaximumAge
  attr_accessor :manufacturerMinimumAge
  attr_accessor :manufacturerPartsWarrantyDescription
  attr_accessor :materialType
  attr_accessor :maximumAperture
  attr_accessor :maximumColorDepth
  attr_accessor :maximumFocalLength
  attr_accessor :maximumHighResolutionImages
  attr_accessor :maximumHorizontalResolution
  attr_accessor :maximumLowResolutionImages
  attr_accessor :maximumResolution
  attr_accessor :maximumShutterSpeed
  attr_accessor :maximumVerticalResolution
  attr_accessor :maximumWeightRecommendation
  attr_accessor :memorySlotsAvailable
  attr_accessor :metalStamp
  attr_accessor :metalType
  attr_accessor :miniMovieDescription
  attr_accessor :minimumFocalLength
  attr_accessor :minimumShutterSpeed
  attr_accessor :model
  attr_accessor :modelYear
  attr_accessor :modemDescription
  attr_accessor :monitorSize
  attr_accessor :monitorViewableDiagonalSize
  attr_accessor :mouseDescription
  attr_accessor :mPN
  attr_accessor :musicalStyle
  attr_accessor :nativeResolution
  attr_accessor :neighborhood
  attr_accessor :networkInterfaceDescription
  attr_accessor :notebookDisplayTechnology
  attr_accessor :notebookPointingDeviceDescription
  attr_accessor :numberOfDiscs
  attr_accessor :numberOfIssues
  attr_accessor :numberOfItems
  attr_accessor :numberOfKeys
  attr_accessor :numberOfPages
  attr_accessor :numberOfPearls
  attr_accessor :numberOfRapidFireShots
  attr_accessor :numberOfStones
  attr_accessor :numberOfStrings
  attr_accessor :numberOfTracks
  attr_accessor :opticalZoom
  attr_accessor :outputWattage
  attr_accessor :packageDimensions
  attr_accessor :pearlLustre
  attr_accessor :pearlMinimumColor
  attr_accessor :pearlShape
  attr_accessor :pearlStringingMethod
  attr_accessor :pearlSurfaceBlemishes
  attr_accessor :pearlType
  attr_accessor :pearlUniformity
  attr_accessor :phoneNumber
  attr_accessor :photoFlashType
  attr_accessor :pictureFormat
  attr_accessor :platform
  attr_accessor :priceRating
  attr_accessor :processorCount
  attr_accessor :productGroup
  attr_accessor :promotionalTag
  attr_accessor :publicationDate
  attr_accessor :publisher
  attr_accessor :readingLevel
  attr_accessor :recorderTrackCount
  attr_accessor :regionCode
  attr_accessor :regionOfOrigin
  attr_accessor :releaseDate
  attr_accessor :removableMemory
  attr_accessor :resolutionModes
  attr_accessor :ringSize
  attr_accessor :runningTime
  attr_accessor :secondaryCacheSize
  attr_accessor :settingType
  attr_accessor :size
  attr_accessor :sizePerPearl
  attr_accessor :skillLevel
  attr_accessor :sKU
  attr_accessor :soundCardDescription
  attr_accessor :speakerCount
  attr_accessor :speakerDescription
  attr_accessor :specialFeatures
  attr_accessor :stoneClarity
  attr_accessor :stoneColor
  attr_accessor :stoneCut
  attr_accessor :stoneShape
  attr_accessor :stoneWeight
  attr_accessor :studio
  attr_accessor :subscriptionLength
  attr_accessor :supportedImageType
  attr_accessor :systemBusSpeed
  attr_accessor :systemMemorySizeMax
  attr_accessor :systemMemorySize
  attr_accessor :systemMemoryType
  attr_accessor :theatricalReleaseDate
  attr_accessor :title
  attr_accessor :totalDiamondWeight
  attr_accessor :totalExternalBaysFree
  attr_accessor :totalFirewirePorts
  attr_accessor :totalGemWeight
  attr_accessor :totalInternalBaysFree
  attr_accessor :totalMetalWeight
  attr_accessor :totalNTSCPALPorts
  attr_accessor :totalParallelPorts
  attr_accessor :totalPCCardSlots
  attr_accessor :totalPCISlotsFree
  attr_accessor :totalSerialPorts
  attr_accessor :totalSVideoOutPorts
  attr_accessor :totalUSB2Ports
  attr_accessor :totalUSBPorts
  attr_accessor :totalVGAOutPorts
  attr_accessor :uPC
  attr_accessor :variationDenomination
  attr_accessor :variationDescription
  attr_accessor :warranty
  attr_accessor :watchMovementType
  attr_accessor :waterResistanceDepth
  attr_accessor :wirelessMicrophoneFrequency

  def initialize(actor = [], address = nil, amazonMaximumAge = nil, amazonMinimumAge = nil, apertureModes = nil, artist = [], aspectRatio = nil, audienceRating = nil, audioFormat = [], author = [], backFinding = nil, bandMaterialType = nil, batteriesIncluded = nil, batteries = nil, batteryDescription = nil, batteryType = nil, bezelMaterialType = nil, binding = nil, brand = nil, calendarType = nil, cameraManualFeatures = [], caseDiameter = nil, caseMaterialType = nil, caseThickness = nil, caseType = nil, cDRWDescription = nil, chainType = nil, claspType = nil, clothingSize = nil, color = nil, compatibility = nil, computerHardwareType = nil, computerPlatform = nil, connectivity = nil, continuousShootingSpeed = nil, country = nil, cPUManufacturer = nil, cPUSpeed = nil, cPUType = nil, creator = [], cuisine = nil, delayBetweenShots = nil, department = nil, deweyDecimalNumber = nil, dialColor = nil, dialWindowMaterialType = nil, digitalZoom = nil, director = [], displaySize = nil, drumSetPieceQuantity = nil, dVDLayers = nil, dVDRWDescription = nil, dVDSides = nil, eAN = nil, edition = nil, eSRBAgeRating = nil, externalDisplaySupportDescription = nil, fabricType = nil, faxNumber = nil, feature = [], firstIssueLeadTime = nil, floppyDiskDriveDescription = nil, format = [], gemType = nil, graphicsCardInterface = nil, graphicsDescription = nil, graphicsMemorySize = nil, guitarAttribute = nil, guitarBridgeSystem = nil, guitarPickThickness = nil, guitarPickupConfiguration = nil, hardDiskCount = nil, hardDiskSize = nil, hasAutoFocus = nil, hasBurstMode = nil, hasInCameraEditing = nil, hasRedEyeReduction = nil, hasSelfTimer = nil, hasTripodMount = nil, hasVideoOut = nil, hasViewfinder = nil, hazardousMaterialType = nil, hoursOfOperation = nil, includedSoftware = nil, includesMp3Player = nil, ingredients = nil, instrumentKey = nil, isAdultProduct = nil, isAutographed = nil, iSBN = nil, isFragile = nil, isLabCreated = nil, isMemorabilia = nil, iSOEquivalent = nil, issuesPerYear = nil, itemDimensions = nil, keyboardDescription = nil, label = nil, languages = nil, legalDisclaimer = nil, lineVoltage = nil, listPrice = nil, macroFocusRange = nil, magazineType = nil, malletHardness = nil, manufacturer = nil, manufacturerLaborWarrantyDescription = nil, manufacturerMaximumAge = nil, manufacturerMinimumAge = nil, manufacturerPartsWarrantyDescription = nil, materialType = nil, maximumAperture = nil, maximumColorDepth = nil, maximumFocalLength = nil, maximumHighResolutionImages = nil, maximumHorizontalResolution = nil, maximumLowResolutionImages = nil, maximumResolution = nil, maximumShutterSpeed = nil, maximumVerticalResolution = nil, maximumWeightRecommendation = nil, memorySlotsAvailable = nil, metalStamp = nil, metalType = nil, miniMovieDescription = nil, minimumFocalLength = nil, minimumShutterSpeed = nil, model = nil, modelYear = nil, modemDescription = nil, monitorSize = nil, monitorViewableDiagonalSize = nil, mouseDescription = nil, mPN = nil, musicalStyle = nil, nativeResolution = nil, neighborhood = nil, networkInterfaceDescription = nil, notebookDisplayTechnology = nil, notebookPointingDeviceDescription = nil, numberOfDiscs = nil, numberOfIssues = nil, numberOfItems = nil, numberOfKeys = nil, numberOfPages = nil, numberOfPearls = nil, numberOfRapidFireShots = nil, numberOfStones = nil, numberOfStrings = nil, numberOfTracks = nil, opticalZoom = nil, outputWattage = nil, packageDimensions = nil, pearlLustre = nil, pearlMinimumColor = nil, pearlShape = nil, pearlStringingMethod = nil, pearlSurfaceBlemishes = nil, pearlType = nil, pearlUniformity = nil, phoneNumber = nil, photoFlashType = [], pictureFormat = [], platform = [], priceRating = nil, processorCount = nil, productGroup = nil, promotionalTag = nil, publicationDate = nil, publisher = nil, readingLevel = nil, recorderTrackCount = nil, regionCode = nil, regionOfOrigin = nil, releaseDate = nil, removableMemory = nil, resolutionModes = nil, ringSize = nil, runningTime = nil, secondaryCacheSize = nil, settingType = nil, size = nil, sizePerPearl = nil, skillLevel = nil, sKU = nil, soundCardDescription = nil, speakerCount = nil, speakerDescription = nil, specialFeatures = [], stoneClarity = nil, stoneColor = nil, stoneCut = nil, stoneShape = nil, stoneWeight = nil, studio = nil, subscriptionLength = nil, supportedImageType = [], systemBusSpeed = nil, systemMemorySizeMax = nil, systemMemorySize = nil, systemMemoryType = nil, theatricalReleaseDate = nil, title = nil, totalDiamondWeight = nil, totalExternalBaysFree = nil, totalFirewirePorts = nil, totalGemWeight = nil, totalInternalBaysFree = nil, totalMetalWeight = nil, totalNTSCPALPorts = nil, totalParallelPorts = nil, totalPCCardSlots = nil, totalPCISlotsFree = nil, totalSerialPorts = nil, totalSVideoOutPorts = nil, totalUSB2Ports = nil, totalUSBPorts = nil, totalVGAOutPorts = nil, uPC = nil, variationDenomination = nil, variationDescription = nil, warranty = nil, watchMovementType = nil, waterResistanceDepth = nil, wirelessMicrophoneFrequency = nil)
    @actor = actor
    @address = address
    @amazonMaximumAge = amazonMaximumAge
    @amazonMinimumAge = amazonMinimumAge
    @apertureModes = apertureModes
    @artist = artist
    @aspectRatio = aspectRatio
    @audienceRating = audienceRating
    @audioFormat = audioFormat
    @author = author
    @backFinding = backFinding
    @bandMaterialType = bandMaterialType
    @batteriesIncluded = batteriesIncluded
    @batteries = batteries
    @batteryDescription = batteryDescription
    @batteryType = batteryType
    @bezelMaterialType = bezelMaterialType
    @binding = binding
    @brand = brand
    @calendarType = calendarType
    @cameraManualFeatures = cameraManualFeatures
    @caseDiameter = caseDiameter
    @caseMaterialType = caseMaterialType
    @caseThickness = caseThickness
    @caseType = caseType
    @cDRWDescription = cDRWDescription
    @chainType = chainType
    @claspType = claspType
    @clothingSize = clothingSize
    @color = color
    @compatibility = compatibility
    @computerHardwareType = computerHardwareType
    @computerPlatform = computerPlatform
    @connectivity = connectivity
    @continuousShootingSpeed = continuousShootingSpeed
    @country = country
    @cPUManufacturer = cPUManufacturer
    @cPUSpeed = cPUSpeed
    @cPUType = cPUType
    @creator = creator
    @cuisine = cuisine
    @delayBetweenShots = delayBetweenShots
    @department = department
    @deweyDecimalNumber = deweyDecimalNumber
    @dialColor = dialColor
    @dialWindowMaterialType = dialWindowMaterialType
    @digitalZoom = digitalZoom
    @director = director
    @displaySize = displaySize
    @drumSetPieceQuantity = drumSetPieceQuantity
    @dVDLayers = dVDLayers
    @dVDRWDescription = dVDRWDescription
    @dVDSides = dVDSides
    @eAN = eAN
    @edition = edition
    @eSRBAgeRating = eSRBAgeRating
    @externalDisplaySupportDescription = externalDisplaySupportDescription
    @fabricType = fabricType
    @faxNumber = faxNumber
    @feature = feature
    @firstIssueLeadTime = firstIssueLeadTime
    @floppyDiskDriveDescription = floppyDiskDriveDescription
    @format = format
    @gemType = gemType
    @graphicsCardInterface = graphicsCardInterface
    @graphicsDescription = graphicsDescription
    @graphicsMemorySize = graphicsMemorySize
    @guitarAttribute = guitarAttribute
    @guitarBridgeSystem = guitarBridgeSystem
    @guitarPickThickness = guitarPickThickness
    @guitarPickupConfiguration = guitarPickupConfiguration
    @hardDiskCount = hardDiskCount
    @hardDiskSize = hardDiskSize
    @hasAutoFocus = hasAutoFocus
    @hasBurstMode = hasBurstMode
    @hasInCameraEditing = hasInCameraEditing
    @hasRedEyeReduction = hasRedEyeReduction
    @hasSelfTimer = hasSelfTimer
    @hasTripodMount = hasTripodMount
    @hasVideoOut = hasVideoOut
    @hasViewfinder = hasViewfinder
    @hazardousMaterialType = hazardousMaterialType
    @hoursOfOperation = hoursOfOperation
    @includedSoftware = includedSoftware
    @includesMp3Player = includesMp3Player
    @ingredients = ingredients
    @instrumentKey = instrumentKey
    @isAdultProduct = isAdultProduct
    @isAutographed = isAutographed
    @iSBN = iSBN
    @isFragile = isFragile
    @isLabCreated = isLabCreated
    @isMemorabilia = isMemorabilia
    @iSOEquivalent = iSOEquivalent
    @issuesPerYear = issuesPerYear
    @itemDimensions = itemDimensions
    @keyboardDescription = keyboardDescription
    @label = label
    @languages = languages
    @legalDisclaimer = legalDisclaimer
    @lineVoltage = lineVoltage
    @listPrice = listPrice
    @macroFocusRange = macroFocusRange
    @magazineType = magazineType
    @malletHardness = malletHardness
    @manufacturer = manufacturer
    @manufacturerLaborWarrantyDescription = manufacturerLaborWarrantyDescription
    @manufacturerMaximumAge = manufacturerMaximumAge
    @manufacturerMinimumAge = manufacturerMinimumAge
    @manufacturerPartsWarrantyDescription = manufacturerPartsWarrantyDescription
    @materialType = materialType
    @maximumAperture = maximumAperture
    @maximumColorDepth = maximumColorDepth
    @maximumFocalLength = maximumFocalLength
    @maximumHighResolutionImages = maximumHighResolutionImages
    @maximumHorizontalResolution = maximumHorizontalResolution
    @maximumLowResolutionImages = maximumLowResolutionImages
    @maximumResolution = maximumResolution
    @maximumShutterSpeed = maximumShutterSpeed
    @maximumVerticalResolution = maximumVerticalResolution
    @maximumWeightRecommendation = maximumWeightRecommendation
    @memorySlotsAvailable = memorySlotsAvailable
    @metalStamp = metalStamp
    @metalType = metalType
    @miniMovieDescription = miniMovieDescription
    @minimumFocalLength = minimumFocalLength
    @minimumShutterSpeed = minimumShutterSpeed
    @model = model
    @modelYear = modelYear
    @modemDescription = modemDescription
    @monitorSize = monitorSize
    @monitorViewableDiagonalSize = monitorViewableDiagonalSize
    @mouseDescription = mouseDescription
    @mPN = mPN
    @musicalStyle = musicalStyle
    @nativeResolution = nativeResolution
    @neighborhood = neighborhood
    @networkInterfaceDescription = networkInterfaceDescription
    @notebookDisplayTechnology = notebookDisplayTechnology
    @notebookPointingDeviceDescription = notebookPointingDeviceDescription
    @numberOfDiscs = numberOfDiscs
    @numberOfIssues = numberOfIssues
    @numberOfItems = numberOfItems
    @numberOfKeys = numberOfKeys
    @numberOfPages = numberOfPages
    @numberOfPearls = numberOfPearls
    @numberOfRapidFireShots = numberOfRapidFireShots
    @numberOfStones = numberOfStones
    @numberOfStrings = numberOfStrings
    @numberOfTracks = numberOfTracks
    @opticalZoom = opticalZoom
    @outputWattage = outputWattage
    @packageDimensions = packageDimensions
    @pearlLustre = pearlLustre
    @pearlMinimumColor = pearlMinimumColor
    @pearlShape = pearlShape
    @pearlStringingMethod = pearlStringingMethod
    @pearlSurfaceBlemishes = pearlSurfaceBlemishes
    @pearlType = pearlType
    @pearlUniformity = pearlUniformity
    @phoneNumber = phoneNumber
    @photoFlashType = photoFlashType
    @pictureFormat = pictureFormat
    @platform = platform
    @priceRating = priceRating
    @processorCount = processorCount
    @productGroup = productGroup
    @promotionalTag = promotionalTag
    @publicationDate = publicationDate
    @publisher = publisher
    @readingLevel = readingLevel
    @recorderTrackCount = recorderTrackCount
    @regionCode = regionCode
    @regionOfOrigin = regionOfOrigin
    @releaseDate = releaseDate
    @removableMemory = removableMemory
    @resolutionModes = resolutionModes
    @ringSize = ringSize
    @runningTime = runningTime
    @secondaryCacheSize = secondaryCacheSize
    @settingType = settingType
    @size = size
    @sizePerPearl = sizePerPearl
    @skillLevel = skillLevel
    @sKU = sKU
    @soundCardDescription = soundCardDescription
    @speakerCount = speakerCount
    @speakerDescription = speakerDescription
    @specialFeatures = specialFeatures
    @stoneClarity = stoneClarity
    @stoneColor = stoneColor
    @stoneCut = stoneCut
    @stoneShape = stoneShape
    @stoneWeight = stoneWeight
    @studio = studio
    @subscriptionLength = subscriptionLength
    @supportedImageType = supportedImageType
    @systemBusSpeed = systemBusSpeed
    @systemMemorySizeMax = systemMemorySizeMax
    @systemMemorySize = systemMemorySize
    @systemMemoryType = systemMemoryType
    @theatricalReleaseDate = theatricalReleaseDate
    @title = title
    @totalDiamondWeight = totalDiamondWeight
    @totalExternalBaysFree = totalExternalBaysFree
    @totalFirewirePorts = totalFirewirePorts
    @totalGemWeight = totalGemWeight
    @totalInternalBaysFree = totalInternalBaysFree
    @totalMetalWeight = totalMetalWeight
    @totalNTSCPALPorts = totalNTSCPALPorts
    @totalParallelPorts = totalParallelPorts
    @totalPCCardSlots = totalPCCardSlots
    @totalPCISlotsFree = totalPCISlotsFree
    @totalSerialPorts = totalSerialPorts
    @totalSVideoOutPorts = totalSVideoOutPorts
    @totalUSB2Ports = totalUSB2Ports
    @totalUSBPorts = totalUSBPorts
    @totalVGAOutPorts = totalVGAOutPorts
    @uPC = uPC
    @variationDenomination = variationDenomination
    @variationDescription = variationDescription
    @warranty = warranty
    @watchMovementType = watchMovementType
    @waterResistanceDepth = waterResistanceDepth
    @wirelessMicrophoneFrequency = wirelessMicrophoneFrequency
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}MerchantItemAttributes
class MerchantItemAttributes
  @@schema_type = "MerchantItemAttributes"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_qualified = "true"
  @@schema_element = [
    ["actor", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Actor")]],
    ["address", ["Address", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Address")]],
    ["amazonMaximumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AmazonMaximumAge")]],
    ["amazonMinimumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AmazonMinimumAge")]],
    ["apertureModes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ApertureModes")]],
    ["artist", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Artist")]],
    ["aspectRatio", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AspectRatio")]],
    ["audienceRating", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AudienceRating")]],
    ["audioFormat", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AudioFormat")]],
    ["author", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Author")]],
    ["backFinding", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BackFinding")]],
    ["bandMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BandMaterialType")]],
    ["batteriesIncluded", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteriesIncluded")]],
    ["batteries", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Batteries")]],
    ["batteryDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteryDescription")]],
    ["batteryType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BatteryType")]],
    ["bezelMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BezelMaterialType")]],
    ["binding", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Binding")]],
    ["brand", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Brand")]],
    ["calendarType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CalendarType")]],
    ["cameraManualFeatures", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CameraManualFeatures")]],
    ["caseDiameter", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseDiameter")]],
    ["caseMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseMaterialType")]],
    ["caseThickness", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseThickness")]],
    ["caseType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CaseType")]],
    ["cDRWDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CDRWDescription")]],
    ["chainType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ChainType")]],
    ["claspType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ClaspType")]],
    ["clothingSize", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ClothingSize")]],
    ["color", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Color")]],
    ["compatibility", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Compatibility")]],
    ["computerHardwareType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ComputerHardwareType")]],
    ["computerPlatform", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ComputerPlatform")]],
    ["connectivity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Connectivity")]],
    ["continuousShootingSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ContinuousShootingSpeed")]],
    ["country", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Country")]],
    ["cPUManufacturer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUManufacturer")]],
    ["cPUSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUSpeed")]],
    ["cPUType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CPUType")]],
    ["creator", ["[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Creator")]],
    ["cuisine", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cuisine")]],
    ["delayBetweenShots", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DelayBetweenShots")]],
    ["department", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Department")]],
    ["description", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Description")]],
    ["deweyDecimalNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeweyDecimalNumber")]],
    ["dialColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DialColor")]],
    ["dialWindowMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DialWindowMaterialType")]],
    ["digitalZoom", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DigitalZoom")]],
    ["director", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Director")]],
    ["displaySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DisplaySize")]],
    ["drumSetPieceQuantity", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DrumSetPieceQuantity")]],
    ["dVDLayers", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDLayers")]],
    ["dVDRWDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDRWDescription")]],
    ["dVDSides", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DVDSides")]],
    ["eAN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "EAN")]],
    ["edition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Edition")]],
    ["eSRBAgeRating", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ESRBAgeRating")]],
    ["externalDisplaySupportDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ExternalDisplaySupportDescription")]],
    ["fabricType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FabricType")]],
    ["faxNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FaxNumber")]],
    ["feature", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Feature")]],
    ["firstIssueLeadTime", ["StringWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FirstIssueLeadTime")]],
    ["floppyDiskDriveDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FloppyDiskDriveDescription")]],
    ["format", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Format")]],
    ["gemType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GemType")]],
    ["graphicsCardInterface", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsCardInterface")]],
    ["graphicsDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsDescription")]],
    ["graphicsMemorySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GraphicsMemorySize")]],
    ["guitarAttribute", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarAttribute")]],
    ["guitarBridgeSystem", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarBridgeSystem")]],
    ["guitarPickThickness", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarPickThickness")]],
    ["guitarPickupConfiguration", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "GuitarPickupConfiguration")]],
    ["hardDiskCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HardDiskCount")]],
    ["hardDiskSize", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HardDiskSize")]],
    ["hasAutoFocus", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasAutoFocus")]],
    ["hasBurstMode", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasBurstMode")]],
    ["hasInCameraEditing", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasInCameraEditing")]],
    ["hasRedEyeReduction", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasRedEyeReduction")]],
    ["hasSelfTimer", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasSelfTimer")]],
    ["hasTripodMount", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasTripodMount")]],
    ["hasVideoOut", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasVideoOut")]],
    ["hasViewfinder", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HasViewfinder")]],
    ["hazardousMaterialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HazardousMaterialType")]],
    ["hoursOfOperation", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HoursOfOperation")]],
    ["includedSoftware", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IncludedSoftware")]],
    ["includesMp3Player", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IncludesMp3Player")]],
    ["indications", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Indications")]],
    ["ingredients", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Ingredients")]],
    ["instrumentKey", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "InstrumentKey")]],
    ["isAutographed", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsAutographed")]],
    ["iSBN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISBN")]],
    ["isFragile", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsFragile")]],
    ["isLabCreated", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsLabCreated")]],
    ["isMemorabilia", ["SOAP::SOAPBoolean", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsMemorabilia")]],
    ["iSOEquivalent", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISOEquivalent")]],
    ["issuesPerYear", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IssuesPerYear")]],
    ["itemDimensions", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemDimensions")]],
    ["keyboardDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "KeyboardDescription")]],
    ["label", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Label")]],
    ["languages", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Languages")]],
    ["legalDisclaimer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LegalDisclaimer")]],
    ["lineVoltage", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LineVoltage")]],
    ["listPrice", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListPrice")]],
    ["macroFocusRange", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MacroFocusRange")]],
    ["magazineType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MagazineType")]],
    ["malletHardness", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MalletHardness")]],
    ["manufacturer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Manufacturer")]],
    ["manufacturerLaborWarrantyDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerLaborWarrantyDescription")]],
    ["manufacturerMaximumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerMaximumAge")]],
    ["manufacturerMinimumAge", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerMinimumAge")]],
    ["manufacturerPartsWarrantyDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ManufacturerPartsWarrantyDescription")]],
    ["materialType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaterialType")]],
    ["maximumAperture", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumAperture")]],
    ["maximumColorDepth", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumColorDepth")]],
    ["maximumFocalLength", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumFocalLength")]],
    ["maximumHighResolutionImages", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumHighResolutionImages")]],
    ["maximumHorizontalResolution", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumHorizontalResolution")]],
    ["maximumLowResolutionImages", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumLowResolutionImages")]],
    ["maximumResolution", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumResolution")]],
    ["maximumShutterSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumShutterSpeed")]],
    ["maximumVerticalResolution", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumVerticalResolution")]],
    ["maximumWeightRecommendation", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumWeightRecommendation")]],
    ["memorySlotsAvailable", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MemorySlotsAvailable")]],
    ["metalStamp", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MetalStamp")]],
    ["metalType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MetalType")]],
    ["miniMovieDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MiniMovieDescription")]],
    ["minimumFocalLength", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MinimumFocalLength")]],
    ["minimumShutterSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MinimumShutterSpeed")]],
    ["model", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Model")]],
    ["modelYear", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ModelYear")]],
    ["modemDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ModemDescription")]],
    ["monitorSize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MonitorSize")]],
    ["monitorViewableDiagonalSize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MonitorViewableDiagonalSize")]],
    ["mouseDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MouseDescription")]],
    ["mPN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MPN")]],
    ["musicalStyle", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MusicalStyle")]],
    ["nativeResolution", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NativeResolution")]],
    ["neighborhood", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Neighborhood")]],
    ["networkInterfaceDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NetworkInterfaceDescription")]],
    ["notebookDisplayTechnology", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NotebookDisplayTechnology")]],
    ["notebookPointingDeviceDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NotebookPointingDeviceDescription")]],
    ["numberOfDiscs", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfDiscs")]],
    ["numberOfIssues", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfIssues")]],
    ["numberOfItems", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfItems")]],
    ["numberOfKeys", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfKeys")]],
    ["numberOfPages", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfPages")]],
    ["numberOfPearls", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfPearls")]],
    ["numberOfRapidFireShots", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfRapidFireShots")]],
    ["numberOfStones", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfStones")]],
    ["numberOfStrings", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfStrings")]],
    ["numberOfTracks", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "NumberOfTracks")]],
    ["opticalZoom", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OpticalZoom")]],
    ["outputWattage", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OutputWattage")]],
    ["packageDimensions", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PackageDimensions")]],
    ["pearlLustre", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlLustre")]],
    ["pearlMinimumColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlMinimumColor")]],
    ["pearlShape", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlShape")]],
    ["pearlStringingMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlStringingMethod")]],
    ["pearlSurfaceBlemishes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlSurfaceBlemishes")]],
    ["pearlType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlType")]],
    ["pearlUniformity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PearlUniformity")]],
    ["phoneNumber", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PhoneNumber")]],
    ["photoFlashType", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PhotoFlashType")]],
    ["pictureFormat", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PictureFormat")]],
    ["platform", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Platform")]],
    ["priceRating", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PriceRating")]],
    ["processorCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProcessorCount")]],
    ["productGroup", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProductGroup")]],
    ["promotionalTag", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PromotionalTag")]],
    ["publicationDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PublicationDate")]],
    ["publisher", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Publisher")]],
    ["readingLevel", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReadingLevel")]],
    ["recorderTrackCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RecorderTrackCount")]],
    ["regionCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RegionCode")]],
    ["regionOfOrigin", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RegionOfOrigin")]],
    ["releaseDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReleaseDate")]],
    ["removableMemory", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RemovableMemory")]],
    ["resolutionModes", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResolutionModes")]],
    ["ringSize", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "RingSize")]],
    ["safetyWarning", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SafetyWarning")]],
    ["secondaryCacheSize", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SecondaryCacheSize")]],
    ["settingType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SettingType")]],
    ["size", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Size")]],
    ["sKU", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SKU")]],
    ["sizePerPearl", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SizePerPearl")]],
    ["skillLevel", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SkillLevel")]],
    ["soundCardDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SoundCardDescription")]],
    ["speakerCount", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpeakerCount")]],
    ["speakerDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpeakerDescription")]],
    ["specialFeatures", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SpecialFeatures")]],
    ["stoneClarity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneClarity")]],
    ["stoneColor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneColor")]],
    ["stoneCut", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneCut")]],
    ["stoneShape", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneShape")]],
    ["stoneWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "StoneWeight")]],
    ["studio", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Studio")]],
    ["subscriptionLength", ["NonNegativeIntegerWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SubscriptionLength")]],
    ["supportedImageType", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SupportedImageType")]],
    ["systemBusSpeed", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemBusSpeed")]],
    ["systemMemorySizeMax", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemorySizeMax")]],
    ["systemMemorySize", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemorySize")]],
    ["systemMemoryType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SystemMemoryType")]],
    ["theatricalReleaseDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TheatricalReleaseDate")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]],
    ["totalDiamondWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalDiamondWeight")]],
    ["totalExternalBaysFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalExternalBaysFree")]],
    ["totalFirewirePorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalFirewirePorts")]],
    ["totalGemWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalGemWeight")]],
    ["totalInternalBaysFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalInternalBaysFree")]],
    ["totalMetalWeight", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalMetalWeight")]],
    ["totalNTSCPALPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalNTSCPALPorts")]],
    ["totalParallelPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalParallelPorts")]],
    ["totalPCCardSlots", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPCCardSlots")]],
    ["totalPCISlotsFree", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalPCISlotsFree")]],
    ["totalSerialPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalSerialPorts")]],
    ["totalSVideoOutPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalSVideoOutPorts")]],
    ["totalUSB2Ports", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalUSB2Ports")]],
    ["totalUSBPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalUSBPorts")]],
    ["totalVGAOutPorts", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TotalVGAOutPorts")]],
    ["uPC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "UPC")]],
    ["variationDenomination", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDenomination")]],
    ["variationDescription", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationDescription")]],
    ["warranty", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Warranty")]],
    ["watchMovementType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WatchMovementType")]],
    ["waterResistanceDepth", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WaterResistanceDepth")]],
    ["wirelessMicrophoneFrequency", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "WirelessMicrophoneFrequency")]]
  ]

  attr_accessor :actor
  attr_accessor :address
  attr_accessor :amazonMaximumAge
  attr_accessor :amazonMinimumAge
  attr_accessor :apertureModes
  attr_accessor :artist
  attr_accessor :aspectRatio
  attr_accessor :audienceRating
  attr_accessor :audioFormat
  attr_accessor :author
  attr_accessor :backFinding
  attr_accessor :bandMaterialType
  attr_accessor :batteriesIncluded
  attr_accessor :batteries
  attr_accessor :batteryDescription
  attr_accessor :batteryType
  attr_accessor :bezelMaterialType
  attr_accessor :binding
  attr_accessor :brand
  attr_accessor :calendarType
  attr_accessor :cameraManualFeatures
  attr_accessor :caseDiameter
  attr_accessor :caseMaterialType
  attr_accessor :caseThickness
  attr_accessor :caseType
  attr_accessor :cDRWDescription
  attr_accessor :chainType
  attr_accessor :claspType
  attr_accessor :clothingSize
  attr_accessor :color
  attr_accessor :compatibility
  attr_accessor :computerHardwareType
  attr_accessor :computerPlatform
  attr_accessor :connectivity
  attr_accessor :continuousShootingSpeed
  attr_accessor :country
  attr_accessor :cPUManufacturer
  attr_accessor :cPUSpeed
  attr_accessor :cPUType
  attr_accessor :creator
  attr_accessor :cuisine
  attr_accessor :delayBetweenShots
  attr_accessor :department
  attr_accessor :description
  attr_accessor :deweyDecimalNumber
  attr_accessor :dialColor
  attr_accessor :dialWindowMaterialType
  attr_accessor :digitalZoom
  attr_accessor :director
  attr_accessor :displaySize
  attr_accessor :drumSetPieceQuantity
  attr_accessor :dVDLayers
  attr_accessor :dVDRWDescription
  attr_accessor :dVDSides
  attr_accessor :eAN
  attr_accessor :edition
  attr_accessor :eSRBAgeRating
  attr_accessor :externalDisplaySupportDescription
  attr_accessor :fabricType
  attr_accessor :faxNumber
  attr_accessor :feature
  attr_accessor :firstIssueLeadTime
  attr_accessor :floppyDiskDriveDescription
  attr_accessor :format
  attr_accessor :gemType
  attr_accessor :graphicsCardInterface
  attr_accessor :graphicsDescription
  attr_accessor :graphicsMemorySize
  attr_accessor :guitarAttribute
  attr_accessor :guitarBridgeSystem
  attr_accessor :guitarPickThickness
  attr_accessor :guitarPickupConfiguration
  attr_accessor :hardDiskCount
  attr_accessor :hardDiskSize
  attr_accessor :hasAutoFocus
  attr_accessor :hasBurstMode
  attr_accessor :hasInCameraEditing
  attr_accessor :hasRedEyeReduction
  attr_accessor :hasSelfTimer
  attr_accessor :hasTripodMount
  attr_accessor :hasVideoOut
  attr_accessor :hasViewfinder
  attr_accessor :hazardousMaterialType
  attr_accessor :hoursOfOperation
  attr_accessor :includedSoftware
  attr_accessor :includesMp3Player
  attr_accessor :indications
  attr_accessor :ingredients
  attr_accessor :instrumentKey
  attr_accessor :isAutographed
  attr_accessor :iSBN
  attr_accessor :isFragile
  attr_accessor :isLabCreated
  attr_accessor :isMemorabilia
  attr_accessor :iSOEquivalent
  attr_accessor :issuesPerYear
  attr_accessor :itemDimensions
  attr_accessor :keyboardDescription
  attr_accessor :label
  attr_accessor :languages
  attr_accessor :legalDisclaimer
  attr_accessor :lineVoltage
  attr_accessor :listPrice
  attr_accessor :macroFocusRange
  attr_accessor :magazineType
  attr_accessor :malletHardness
  attr_accessor :manufacturer
  attr_accessor :manufacturerLaborWarrantyDescription
  attr_accessor :manufacturerMaximumAge
  attr_accessor :manufacturerMinimumAge
  attr_accessor :manufacturerPartsWarrantyDescription
  attr_accessor :materialType
  attr_accessor :maximumAperture
  attr_accessor :maximumColorDepth
  attr_accessor :maximumFocalLength
  attr_accessor :maximumHighResolutionImages
  attr_accessor :maximumHorizontalResolution
  attr_accessor :maximumLowResolutionImages
  attr_accessor :maximumResolution
  attr_accessor :maximumShutterSpeed
  attr_accessor :maximumVerticalResolution
  attr_accessor :maximumWeightRecommendation
  attr_accessor :memorySlotsAvailable
  attr_accessor :metalStamp
  attr_accessor :metalType
  attr_accessor :miniMovieDescription
  attr_accessor :minimumFocalLength
  attr_accessor :minimumShutterSpeed
  attr_accessor :model
  attr_accessor :modelYear
  attr_accessor :modemDescription
  attr_accessor :monitorSize
  attr_accessor :monitorViewableDiagonalSize
  attr_accessor :mouseDescription
  attr_accessor :mPN
  attr_accessor :musicalStyle
  attr_accessor :nativeResolution
  attr_accessor :neighborhood
  attr_accessor :networkInterfaceDescription
  attr_accessor :notebookDisplayTechnology
  attr_accessor :notebookPointingDeviceDescription
  attr_accessor :numberOfDiscs
  attr_accessor :numberOfIssues
  attr_accessor :numberOfItems
  attr_accessor :numberOfKeys
  attr_accessor :numberOfPages
  attr_accessor :numberOfPearls
  attr_accessor :numberOfRapidFireShots
  attr_accessor :numberOfStones
  attr_accessor :numberOfStrings
  attr_accessor :numberOfTracks
  attr_accessor :opticalZoom
  attr_accessor :outputWattage
  attr_accessor :packageDimensions
  attr_accessor :pearlLustre
  attr_accessor :pearlMinimumColor
  attr_accessor :pearlShape
  attr_accessor :pearlStringingMethod
  attr_accessor :pearlSurfaceBlemishes
  attr_accessor :pearlType
  attr_accessor :pearlUniformity
  attr_accessor :phoneNumber
  attr_accessor :photoFlashType
  attr_accessor :pictureFormat
  attr_accessor :platform
  attr_accessor :priceRating
  attr_accessor :processorCount
  attr_accessor :productGroup
  attr_accessor :promotionalTag
  attr_accessor :publicationDate
  attr_accessor :publisher
  attr_accessor :readingLevel
  attr_accessor :recorderTrackCount
  attr_accessor :regionCode
  attr_accessor :regionOfOrigin
  attr_accessor :releaseDate
  attr_accessor :removableMemory
  attr_accessor :resolutionModes
  attr_accessor :ringSize
  attr_accessor :safetyWarning
  attr_accessor :secondaryCacheSize
  attr_accessor :settingType
  attr_accessor :size
  attr_accessor :sKU
  attr_accessor :sizePerPearl
  attr_accessor :skillLevel
  attr_accessor :soundCardDescription
  attr_accessor :speakerCount
  attr_accessor :speakerDescription
  attr_accessor :specialFeatures
  attr_accessor :stoneClarity
  attr_accessor :stoneColor
  attr_accessor :stoneCut
  attr_accessor :stoneShape
  attr_accessor :stoneWeight
  attr_accessor :studio
  attr_accessor :subscriptionLength
  attr_accessor :supportedImageType
  attr_accessor :systemBusSpeed
  attr_accessor :systemMemorySizeMax
  attr_accessor :systemMemorySize
  attr_accessor :systemMemoryType
  attr_accessor :theatricalReleaseDate
  attr_accessor :title
  attr_accessor :totalDiamondWeight
  attr_accessor :totalExternalBaysFree
  attr_accessor :totalFirewirePorts
  attr_accessor :totalGemWeight
  attr_accessor :totalInternalBaysFree
  attr_accessor :totalMetalWeight
  attr_accessor :totalNTSCPALPorts
  attr_accessor :totalParallelPorts
  attr_accessor :totalPCCardSlots
  attr_accessor :totalPCISlotsFree
  attr_accessor :totalSerialPorts
  attr_accessor :totalSVideoOutPorts
  attr_accessor :totalUSB2Ports
  attr_accessor :totalUSBPorts
  attr_accessor :totalVGAOutPorts
  attr_accessor :uPC
  attr_accessor :variationDenomination
  attr_accessor :variationDescription
  attr_accessor :warranty
  attr_accessor :watchMovementType
  attr_accessor :waterResistanceDepth
  attr_accessor :wirelessMicrophoneFrequency

  def initialize(actor = [], address = nil, amazonMaximumAge = nil, amazonMinimumAge = nil, apertureModes = nil, artist = [], aspectRatio = nil, audienceRating = nil, audioFormat = [], author = [], backFinding = nil, bandMaterialType = nil, batteriesIncluded = nil, batteries = nil, batteryDescription = nil, batteryType = nil, bezelMaterialType = nil, binding = nil, brand = nil, calendarType = nil, cameraManualFeatures = [], caseDiameter = nil, caseMaterialType = nil, caseThickness = nil, caseType = nil, cDRWDescription = nil, chainType = nil, claspType = nil, clothingSize = nil, color = nil, compatibility = nil, computerHardwareType = nil, computerPlatform = nil, connectivity = nil, continuousShootingSpeed = nil, country = nil, cPUManufacturer = nil, cPUSpeed = nil, cPUType = nil, creator = [], cuisine = nil, delayBetweenShots = nil, department = nil, description = nil, deweyDecimalNumber = nil, dialColor = nil, dialWindowMaterialType = nil, digitalZoom = nil, director = [], displaySize = nil, drumSetPieceQuantity = nil, dVDLayers = nil, dVDRWDescription = nil, dVDSides = nil, eAN = nil, edition = nil, eSRBAgeRating = nil, externalDisplaySupportDescription = nil, fabricType = nil, faxNumber = nil, feature = [], firstIssueLeadTime = nil, floppyDiskDriveDescription = nil, format = [], gemType = nil, graphicsCardInterface = nil, graphicsDescription = nil, graphicsMemorySize = nil, guitarAttribute = nil, guitarBridgeSystem = nil, guitarPickThickness = nil, guitarPickupConfiguration = nil, hardDiskCount = nil, hardDiskSize = nil, hasAutoFocus = nil, hasBurstMode = nil, hasInCameraEditing = nil, hasRedEyeReduction = nil, hasSelfTimer = nil, hasTripodMount = nil, hasVideoOut = nil, hasViewfinder = nil, hazardousMaterialType = nil, hoursOfOperation = nil, includedSoftware = nil, includesMp3Player = nil, indications = nil, ingredients = nil, instrumentKey = nil, isAutographed = nil, iSBN = nil, isFragile = nil, isLabCreated = nil, isMemorabilia = nil, iSOEquivalent = nil, issuesPerYear = nil, itemDimensions = nil, keyboardDescription = nil, label = nil, languages = nil, legalDisclaimer = nil, lineVoltage = nil, listPrice = nil, macroFocusRange = nil, magazineType = nil, malletHardness = nil, manufacturer = nil, manufacturerLaborWarrantyDescription = nil, manufacturerMaximumAge = nil, manufacturerMinimumAge = nil, manufacturerPartsWarrantyDescription = nil, materialType = nil, maximumAperture = nil, maximumColorDepth = nil, maximumFocalLength = nil, maximumHighResolutionImages = nil, maximumHorizontalResolution = nil, maximumLowResolutionImages = nil, maximumResolution = nil, maximumShutterSpeed = nil, maximumVerticalResolution = nil, maximumWeightRecommendation = nil, memorySlotsAvailable = nil, metalStamp = nil, metalType = nil, miniMovieDescription = nil, minimumFocalLength = nil, minimumShutterSpeed = nil, model = nil, modelYear = nil, modemDescription = nil, monitorSize = nil, monitorViewableDiagonalSize = nil, mouseDescription = nil, mPN = nil, musicalStyle = nil, nativeResolution = nil, neighborhood = nil, networkInterfaceDescription = nil, notebookDisplayTechnology = nil, notebookPointingDeviceDescription = nil, numberOfDiscs = nil, numberOfIssues = nil, numberOfItems = nil, numberOfKeys = nil, numberOfPages = nil, numberOfPearls = nil, numberOfRapidFireShots = nil, numberOfStones = nil, numberOfStrings = nil, numberOfTracks = nil, opticalZoom = nil, outputWattage = nil, packageDimensions = nil, pearlLustre = nil, pearlMinimumColor = nil, pearlShape = nil, pearlStringingMethod = nil, pearlSurfaceBlemishes = nil, pearlType = nil, pearlUniformity = nil, phoneNumber = nil, photoFlashType = [], pictureFormat = [], platform = [], priceRating = nil, processorCount = nil, productGroup = nil, promotionalTag = nil, publicationDate = nil, publisher = nil, readingLevel = nil, recorderTrackCount = nil, regionCode = nil, regionOfOrigin = nil, releaseDate = nil, removableMemory = nil, resolutionModes = nil, ringSize = nil, safetyWarning = nil, secondaryCacheSize = nil, settingType = nil, size = nil, sKU = nil, sizePerPearl = nil, skillLevel = nil, soundCardDescription = nil, speakerCount = nil, speakerDescription = nil, specialFeatures = [], stoneClarity = nil, stoneColor = nil, stoneCut = nil, stoneShape = nil, stoneWeight = nil, studio = nil, subscriptionLength = nil, supportedImageType = [], systemBusSpeed = nil, systemMemorySizeMax = nil, systemMemorySize = nil, systemMemoryType = nil, theatricalReleaseDate = nil, title = nil, totalDiamondWeight = nil, totalExternalBaysFree = nil, totalFirewirePorts = nil, totalGemWeight = nil, totalInternalBaysFree = nil, totalMetalWeight = nil, totalNTSCPALPorts = nil, totalParallelPorts = nil, totalPCCardSlots = nil, totalPCISlotsFree = nil, totalSerialPorts = nil, totalSVideoOutPorts = nil, totalUSB2Ports = nil, totalUSBPorts = nil, totalVGAOutPorts = nil, uPC = nil, variationDenomination = nil, variationDescription = nil, warranty = nil, watchMovementType = nil, waterResistanceDepth = nil, wirelessMicrophoneFrequency = nil)
    @actor = actor
    @address = address
    @amazonMaximumAge = amazonMaximumAge
    @amazonMinimumAge = amazonMinimumAge
    @apertureModes = apertureModes
    @artist = artist
    @aspectRatio = aspectRatio
    @audienceRating = audienceRating
    @audioFormat = audioFormat
    @author = author
    @backFinding = backFinding
    @bandMaterialType = bandMaterialType
    @batteriesIncluded = batteriesIncluded
    @batteries = batteries
    @batteryDescription = batteryDescription
    @batteryType = batteryType
    @bezelMaterialType = bezelMaterialType
    @binding = binding
    @brand = brand
    @calendarType = calendarType
    @cameraManualFeatures = cameraManualFeatures
    @caseDiameter = caseDiameter
    @caseMaterialType = caseMaterialType
    @caseThickness = caseThickness
    @caseType = caseType
    @cDRWDescription = cDRWDescription
    @chainType = chainType
    @claspType = claspType
    @clothingSize = clothingSize
    @color = color
    @compatibility = compatibility
    @computerHardwareType = computerHardwareType
    @computerPlatform = computerPlatform
    @connectivity = connectivity
    @continuousShootingSpeed = continuousShootingSpeed
    @country = country
    @cPUManufacturer = cPUManufacturer
    @cPUSpeed = cPUSpeed
    @cPUType = cPUType
    @creator = creator
    @cuisine = cuisine
    @delayBetweenShots = delayBetweenShots
    @department = department
    @description = description
    @deweyDecimalNumber = deweyDecimalNumber
    @dialColor = dialColor
    @dialWindowMaterialType = dialWindowMaterialType
    @digitalZoom = digitalZoom
    @director = director
    @displaySize = displaySize
    @drumSetPieceQuantity = drumSetPieceQuantity
    @dVDLayers = dVDLayers
    @dVDRWDescription = dVDRWDescription
    @dVDSides = dVDSides
    @eAN = eAN
    @edition = edition
    @eSRBAgeRating = eSRBAgeRating
    @externalDisplaySupportDescription = externalDisplaySupportDescription
    @fabricType = fabricType
    @faxNumber = faxNumber
    @feature = feature
    @firstIssueLeadTime = firstIssueLeadTime
    @floppyDiskDriveDescription = floppyDiskDriveDescription
    @format = format
    @gemType = gemType
    @graphicsCardInterface = graphicsCardInterface
    @graphicsDescription = graphicsDescription
    @graphicsMemorySize = graphicsMemorySize
    @guitarAttribute = guitarAttribute
    @guitarBridgeSystem = guitarBridgeSystem
    @guitarPickThickness = guitarPickThickness
    @guitarPickupConfiguration = guitarPickupConfiguration
    @hardDiskCount = hardDiskCount
    @hardDiskSize = hardDiskSize
    @hasAutoFocus = hasAutoFocus
    @hasBurstMode = hasBurstMode
    @hasInCameraEditing = hasInCameraEditing
    @hasRedEyeReduction = hasRedEyeReduction
    @hasSelfTimer = hasSelfTimer
    @hasTripodMount = hasTripodMount
    @hasVideoOut = hasVideoOut
    @hasViewfinder = hasViewfinder
    @hazardousMaterialType = hazardousMaterialType
    @hoursOfOperation = hoursOfOperation
    @includedSoftware = includedSoftware
    @includesMp3Player = includesMp3Player
    @indications = indications
    @ingredients = ingredients
    @instrumentKey = instrumentKey
    @isAutographed = isAutographed
    @iSBN = iSBN
    @isFragile = isFragile
    @isLabCreated = isLabCreated
    @isMemorabilia = isMemorabilia
    @iSOEquivalent = iSOEquivalent
    @issuesPerYear = issuesPerYear
    @itemDimensions = itemDimensions
    @keyboardDescription = keyboardDescription
    @label = label
    @languages = languages
    @legalDisclaimer = legalDisclaimer
    @lineVoltage = lineVoltage
    @listPrice = listPrice
    @macroFocusRange = macroFocusRange
    @magazineType = magazineType
    @malletHardness = malletHardness
    @manufacturer = manufacturer
    @manufacturerLaborWarrantyDescription = manufacturerLaborWarrantyDescription
    @manufacturerMaximumAge = manufacturerMaximumAge
    @manufacturerMinimumAge = manufacturerMinimumAge
    @manufacturerPartsWarrantyDescription = manufacturerPartsWarrantyDescription
    @materialType = materialType
    @maximumAperture = maximumAperture
    @maximumColorDepth = maximumColorDepth
    @maximumFocalLength = maximumFocalLength
    @maximumHighResolutionImages = maximumHighResolutionImages
    @maximumHorizontalResolution = maximumHorizontalResolution
    @maximumLowResolutionImages = maximumLowResolutionImages
    @maximumResolution = maximumResolution
    @maximumShutterSpeed = maximumShutterSpeed
    @maximumVerticalResolution = maximumVerticalResolution
    @maximumWeightRecommendation = maximumWeightRecommendation
    @memorySlotsAvailable = memorySlotsAvailable
    @metalStamp = metalStamp
    @metalType = metalType
    @miniMovieDescription = miniMovieDescription
    @minimumFocalLength = minimumFocalLength
    @minimumShutterSpeed = minimumShutterSpeed
    @model = model
    @modelYear = modelYear
    @modemDescription = modemDescription
    @monitorSize = monitorSize
    @monitorViewableDiagonalSize = monitorViewableDiagonalSize
    @mouseDescription = mouseDescription
    @mPN = mPN
    @musicalStyle = musicalStyle
    @nativeResolution = nativeResolution
    @neighborhood = neighborhood
    @networkInterfaceDescription = networkInterfaceDescription
    @notebookDisplayTechnology = notebookDisplayTechnology
    @notebookPointingDeviceDescription = notebookPointingDeviceDescription
    @numberOfDiscs = numberOfDiscs
    @numberOfIssues = numberOfIssues
    @numberOfItems = numberOfItems
    @numberOfKeys = numberOfKeys
    @numberOfPages = numberOfPages
    @numberOfPearls = numberOfPearls
    @numberOfRapidFireShots = numberOfRapidFireShots
    @numberOfStones = numberOfStones
    @numberOfStrings = numberOfStrings
    @numberOfTracks = numberOfTracks
    @opticalZoom = opticalZoom
    @outputWattage = outputWattage
    @packageDimensions = packageDimensions
    @pearlLustre = pearlLustre
    @pearlMinimumColor = pearlMinimumColor
    @pearlShape = pearlShape
    @pearlStringingMethod = pearlStringingMethod
    @pearlSurfaceBlemishes = pearlSurfaceBlemishes
    @pearlType = pearlType
    @pearlUniformity = pearlUniformity
    @phoneNumber = phoneNumber
    @photoFlashType = photoFlashType
    @pictureFormat = pictureFormat
    @platform = platform
    @priceRating = priceRating
    @processorCount = processorCount
    @productGroup = productGroup
    @promotionalTag = promotionalTag
    @publicationDate = publicationDate
    @publisher = publisher
    @readingLevel = readingLevel
    @recorderTrackCount = recorderTrackCount
    @regionCode = regionCode
    @regionOfOrigin = regionOfOrigin
    @releaseDate = releaseDate
    @removableMemory = removableMemory
    @resolutionModes = resolutionModes
    @ringSize = ringSize
    @safetyWarning = safetyWarning
    @secondaryCacheSize = secondaryCacheSize
    @settingType = settingType
    @size = size
    @sKU = sKU
    @sizePerPearl = sizePerPearl
    @skillLevel = skillLevel
    @soundCardDescription = soundCardDescription
    @speakerCount = speakerCount
    @speakerDescription = speakerDescription
    @specialFeatures = specialFeatures
    @stoneClarity = stoneClarity
    @stoneColor = stoneColor
    @stoneCut = stoneCut
    @stoneShape = stoneShape
    @stoneWeight = stoneWeight
    @studio = studio
    @subscriptionLength = subscriptionLength
    @supportedImageType = supportedImageType
    @systemBusSpeed = systemBusSpeed
    @systemMemorySizeMax = systemMemorySizeMax
    @systemMemorySize = systemMemorySize
    @systemMemoryType = systemMemoryType
    @theatricalReleaseDate = theatricalReleaseDate
    @title = title
    @totalDiamondWeight = totalDiamondWeight
    @totalExternalBaysFree = totalExternalBaysFree
    @totalFirewirePorts = totalFirewirePorts
    @totalGemWeight = totalGemWeight
    @totalInternalBaysFree = totalInternalBaysFree
    @totalMetalWeight = totalMetalWeight
    @totalNTSCPALPorts = totalNTSCPALPorts
    @totalParallelPorts = totalParallelPorts
    @totalPCCardSlots = totalPCCardSlots
    @totalPCISlotsFree = totalPCISlotsFree
    @totalSerialPorts = totalSerialPorts
    @totalSVideoOutPorts = totalSVideoOutPorts
    @totalUSB2Ports = totalUSB2Ports
    @totalUSBPorts = totalUSBPorts
    @totalVGAOutPorts = totalVGAOutPorts
    @uPC = uPC
    @variationDenomination = variationDenomination
    @variationDescription = variationDescription
    @warranty = warranty
    @watchMovementType = watchMovementType
    @waterResistanceDepth = waterResistanceDepth
    @wirelessMicrophoneFrequency = wirelessMicrophoneFrequency
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}HelpRequest
class HelpRequest
  @@schema_type = "HelpRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["about", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "About")]],
    ["helpType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HelpType")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :about
  attr_accessor :helpType
  attr_accessor :responseGroup

  def initialize(about = nil, helpType = nil, responseGroup = [])
    @about = about
    @helpType = helpType
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemSearchRequest
class ItemSearchRequest
  @@schema_type = "ItemSearchRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["actor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Actor")]],
    ["artist", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Artist")]],
    ["availability", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Availability")]],
    ["audienceRating", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "AudienceRating")]],
    ["author", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Author")]],
    ["brand", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Brand")]],
    ["browseNode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNode")]],
    ["city", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "City")]],
    ["composer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Composer")]],
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["conductor", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Conductor")]],
    ["count", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Count")]],
    ["cuisine", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Cuisine")]],
    ["deliveryMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeliveryMethod")]],
    ["director", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Director")]],
    ["futureLaunchDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FutureLaunchDate")]],
    ["iSPUPostalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUPostalCode")]],
    ["itemPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemPage")]],
    ["keywords", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Keywords")]],
    ["manufacturer", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Manufacturer")]],
    ["maximumPrice", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MaximumPrice")]],
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["minimumPrice", ["SOAP::SOAPNonNegativeInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MinimumPrice")]],
    ["musicLabel", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MusicLabel")]],
    ["neighborhood", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Neighborhood")]],
    ["orchestra", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Orchestra")]],
    ["postalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PostalCode")]],
    ["power", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Power")]],
    ["publisher", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Publisher")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["searchIndex", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchIndex")]],
    ["sort", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Sort")]],
    ["state", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "State")]],
    ["textStream", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TextStream")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]],
    ["releaseDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReleaseDate")]]
  ]

  attr_accessor :actor
  attr_accessor :artist
  attr_accessor :availability
  attr_accessor :audienceRating
  attr_accessor :author
  attr_accessor :brand
  attr_accessor :browseNode
  attr_accessor :city
  attr_accessor :composer
  attr_accessor :condition
  attr_accessor :conductor
  attr_accessor :count
  attr_accessor :cuisine
  attr_accessor :deliveryMethod
  attr_accessor :director
  attr_accessor :futureLaunchDate
  attr_accessor :iSPUPostalCode
  attr_accessor :itemPage
  attr_accessor :keywords
  attr_accessor :manufacturer
  attr_accessor :maximumPrice
  attr_accessor :merchantId
  attr_accessor :minimumPrice
  attr_accessor :musicLabel
  attr_accessor :neighborhood
  attr_accessor :orchestra
  attr_accessor :postalCode
  attr_accessor :power
  attr_accessor :publisher
  attr_accessor :responseGroup
  attr_accessor :searchIndex
  attr_accessor :sort
  attr_accessor :state
  attr_accessor :textStream
  attr_accessor :title
  attr_accessor :releaseDate

  def initialize(actor = nil, artist = nil, availability = nil, audienceRating = [], author = nil, brand = nil, browseNode = nil, city = nil, composer = nil, condition = nil, conductor = nil, count = nil, cuisine = nil, deliveryMethod = nil, director = nil, futureLaunchDate = nil, iSPUPostalCode = nil, itemPage = nil, keywords = nil, manufacturer = nil, maximumPrice = nil, merchantId = nil, minimumPrice = nil, musicLabel = nil, neighborhood = nil, orchestra = nil, postalCode = nil, power = nil, publisher = nil, responseGroup = [], searchIndex = nil, sort = nil, state = nil, textStream = nil, title = nil, releaseDate = nil)
    @actor = actor
    @artist = artist
    @availability = availability
    @audienceRating = audienceRating
    @author = author
    @brand = brand
    @browseNode = browseNode
    @city = city
    @composer = composer
    @condition = condition
    @conductor = conductor
    @count = count
    @cuisine = cuisine
    @deliveryMethod = deliveryMethod
    @director = director
    @futureLaunchDate = futureLaunchDate
    @iSPUPostalCode = iSPUPostalCode
    @itemPage = itemPage
    @keywords = keywords
    @manufacturer = manufacturer
    @maximumPrice = maximumPrice
    @merchantId = merchantId
    @minimumPrice = minimumPrice
    @musicLabel = musicLabel
    @neighborhood = neighborhood
    @orchestra = orchestra
    @postalCode = postalCode
    @power = power
    @publisher = publisher
    @responseGroup = responseGroup
    @searchIndex = searchIndex
    @sort = sort
    @state = state
    @textStream = textStream
    @title = title
    @releaseDate = releaseDate
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ItemLookupRequest
class ItemLookupRequest
  @@schema_type = "ItemLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["deliveryMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeliveryMethod")]],
    ["futureLaunchDate", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FutureLaunchDate")]],
    ["idType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IdType")]],
    ["iSPUPostalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUPostalCode")]],
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["offerPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferPage")]],
    ["itemId", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemId")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["reviewPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReviewPage")]],
    ["searchIndex", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchIndex")]],
    ["searchInsideKeywords", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SearchInsideKeywords")]],
    ["variationPage", ["PositiveIntegerOrAll", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "VariationPage")]]
  ]

  attr_accessor :condition
  attr_accessor :deliveryMethod
  attr_accessor :futureLaunchDate
  attr_accessor :idType
  attr_accessor :iSPUPostalCode
  attr_accessor :merchantId
  attr_accessor :offerPage
  attr_accessor :itemId
  attr_accessor :responseGroup
  attr_accessor :reviewPage
  attr_accessor :searchIndex
  attr_accessor :searchInsideKeywords
  attr_accessor :variationPage

  def initialize(condition = nil, deliveryMethod = nil, futureLaunchDate = nil, idType = nil, iSPUPostalCode = nil, merchantId = nil, offerPage = nil, itemId = [], responseGroup = [], reviewPage = nil, searchIndex = nil, searchInsideKeywords = nil, variationPage = nil)
    @condition = condition
    @deliveryMethod = deliveryMethod
    @futureLaunchDate = futureLaunchDate
    @idType = idType
    @iSPUPostalCode = iSPUPostalCode
    @merchantId = merchantId
    @offerPage = offerPage
    @itemId = itemId
    @responseGroup = responseGroup
    @reviewPage = reviewPage
    @searchIndex = searchIndex
    @searchInsideKeywords = searchInsideKeywords
    @variationPage = variationPage
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListSearchRequest
class ListSearchRequest
  @@schema_type = "ListSearchRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["city", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "City")]],
    ["email", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Email")]],
    ["firstName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FirstName")]],
    ["lastName", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "LastName")]],
    ["listPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListPage")]],
    ["listType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListType")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["state", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "State")]]
  ]

  attr_accessor :city
  attr_accessor :email
  attr_accessor :firstName
  attr_accessor :lastName
  attr_accessor :listPage
  attr_accessor :listType
  attr_accessor :name
  attr_accessor :responseGroup
  attr_accessor :state

  def initialize(city = nil, email = nil, firstName = nil, lastName = nil, listPage = nil, listType = nil, name = nil, responseGroup = [], state = nil)
    @city = city
    @email = email
    @firstName = firstName
    @lastName = lastName
    @listPage = listPage
    @listType = listType
    @name = name
    @responseGroup = responseGroup
    @state = state
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}ListLookupRequest
class ListLookupRequest
  @@schema_type = "ListLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["deliveryMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeliveryMethod")]],
    ["iSPUPostalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUPostalCode")]],
    ["listId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListId")]],
    ["listType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListType")]],
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["productGroup", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProductGroup")]],
    ["productPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProductPage")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["sort", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Sort")]]
  ]

  attr_accessor :condition
  attr_accessor :deliveryMethod
  attr_accessor :iSPUPostalCode
  attr_accessor :listId
  attr_accessor :listType
  attr_accessor :merchantId
  attr_accessor :productGroup
  attr_accessor :productPage
  attr_accessor :responseGroup
  attr_accessor :sort

  def initialize(condition = nil, deliveryMethod = nil, iSPUPostalCode = nil, listId = nil, listType = nil, merchantId = nil, productGroup = nil, productPage = nil, responseGroup = [], sort = nil)
    @condition = condition
    @deliveryMethod = deliveryMethod
    @iSPUPostalCode = iSPUPostalCode
    @listId = listId
    @listType = listType
    @merchantId = merchantId
    @productGroup = productGroup
    @productPage = productPage
    @responseGroup = responseGroup
    @sort = sort
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentSearchRequest
class CustomerContentSearchRequest
  @@schema_type = "CustomerContentSearchRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["customerPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerPage")]],
    ["email", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Email")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :customerPage
  attr_accessor :email
  attr_accessor :name
  attr_accessor :responseGroup

  def initialize(customerPage = nil, email = nil, name = nil, responseGroup = [])
    @customerPage = customerPage
    @email = email
    @name = name
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CustomerContentLookupRequest
class CustomerContentLookupRequest
  @@schema_type = "CustomerContentLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["customerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CustomerId")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["reviewPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ReviewPage")]]
  ]

  attr_accessor :customerId
  attr_accessor :responseGroup
  attr_accessor :reviewPage

  def initialize(customerId = nil, responseGroup = [], reviewPage = nil)
    @customerId = customerId
    @responseGroup = responseGroup
    @reviewPage = reviewPage
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SimilarityLookupRequest
class SimilarityLookupRequest
  @@schema_type = "SimilarityLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["condition", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Condition")]],
    ["deliveryMethod", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "DeliveryMethod")]],
    ["itemId", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemId")]],
    ["iSPUPostalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ISPUPostalCode")]],
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["similarityType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SimilarityType")]]
  ]

  attr_accessor :condition
  attr_accessor :deliveryMethod
  attr_accessor :itemId
  attr_accessor :iSPUPostalCode
  attr_accessor :merchantId
  attr_accessor :responseGroup
  attr_accessor :similarityType

  def initialize(condition = nil, deliveryMethod = nil, itemId = [], iSPUPostalCode = nil, merchantId = nil, responseGroup = [], similarityType = nil)
    @condition = condition
    @deliveryMethod = deliveryMethod
    @itemId = itemId
    @iSPUPostalCode = iSPUPostalCode
    @merchantId = merchantId
    @responseGroup = responseGroup
    @similarityType = similarityType
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerLookupRequest
class SellerLookupRequest
  @@schema_type = "SellerLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["sellerId", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["feedbackPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FeedbackPage")]]
  ]

  attr_accessor :responseGroup
  attr_accessor :sellerId
  attr_accessor :feedbackPage

  def initialize(responseGroup = [], sellerId = [], feedbackPage = nil)
    @responseGroup = responseGroup
    @sellerId = sellerId
    @feedbackPage = feedbackPage
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartGetRequest
class CartGetRequest
  @@schema_type = "CartGetRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["cartId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartId")]],
    ["hMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HMAC")]],
    ["mergeCart", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MergeCart")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :cartId
  attr_accessor :hMAC
  attr_accessor :mergeCart
  attr_accessor :responseGroup

  def initialize(cartId = nil, hMAC = nil, mergeCart = nil, responseGroup = [])
    @cartId = cartId
    @hMAC = hMAC
    @mergeCart = mergeCart
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartAddRequest
class CartAddRequest
  @@schema_type = "CartAddRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["cartId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartId")]],
    ["hMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HMAC")]],
    ["mergeCart", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MergeCart")]],
    ["items", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :cartId
  attr_accessor :hMAC
  attr_accessor :mergeCart
  attr_accessor :items
  attr_accessor :responseGroup

  def initialize(cartId = nil, hMAC = nil, mergeCart = nil, items = nil, responseGroup = [])
    @cartId = cartId
    @hMAC = hMAC
    @mergeCart = mergeCart
    @items = items
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartCreateRequest
class CartCreateRequest
  @@schema_type = "CartCreateRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["mergeCart", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MergeCart")]],
    ["items", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :mergeCart
  attr_accessor :items
  attr_accessor :responseGroup

  def initialize(mergeCart = nil, items = nil, responseGroup = [])
    @mergeCart = mergeCart
    @items = items
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartModifyRequest
class CartModifyRequest
  @@schema_type = "CartModifyRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["cartId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartId")]],
    ["hMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HMAC")]],
    ["mergeCart", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MergeCart")]],
    ["items", [nil, XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Items")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :cartId
  attr_accessor :hMAC
  attr_accessor :mergeCart
  attr_accessor :items
  attr_accessor :responseGroup

  def initialize(cartId = nil, hMAC = nil, mergeCart = nil, items = nil, responseGroup = [])
    @cartId = cartId
    @hMAC = hMAC
    @mergeCart = mergeCart
    @items = items
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartClearRequest
class CartClearRequest
  @@schema_type = "CartClearRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["cartId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartId")]],
    ["hMAC", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "HMAC")]],
    ["mergeCart", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MergeCart")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :cartId
  attr_accessor :hMAC
  attr_accessor :mergeCart
  attr_accessor :responseGroup

  def initialize(cartId = nil, hMAC = nil, mergeCart = nil, responseGroup = [])
    @cartId = cartId
    @hMAC = hMAC
    @mergeCart = mergeCart
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}TransactionLookupRequest
class TransactionLookupRequest
  @@schema_type = "TransactionLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["transactionId", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "TransactionId")]]
  ]

  attr_accessor :responseGroup
  attr_accessor :transactionId

  def initialize(responseGroup = [], transactionId = [])
    @responseGroup = responseGroup
    @transactionId = transactionId
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingSearchRequest
class SellerListingSearchRequest
  @@schema_type = "SellerListingSearchRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["keywords", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Keywords")]],
    ["listingPage", ["SOAP::SOAPPositiveInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListingPage")]],
    ["offerStatus", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "OfferStatus")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]],
    ["sellerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["sort", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Sort")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]]
  ]

  attr_accessor :keywords
  attr_accessor :listingPage
  attr_accessor :offerStatus
  attr_accessor :responseGroup
  attr_accessor :sellerId
  attr_accessor :sort
  attr_accessor :title

  def initialize(keywords = nil, listingPage = nil, offerStatus = nil, responseGroup = [], sellerId = nil, sort = nil, title = nil)
    @keywords = keywords
    @listingPage = listingPage
    @offerStatus = offerStatus
    @responseGroup = responseGroup
    @sellerId = sellerId
    @sort = sort
    @title = title
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}SellerListingLookupRequest
class SellerListingLookupRequest
  @@schema_type = "SellerListingLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["id", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Id")]],
    ["sellerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["idType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IdType")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :id
  attr_accessor :sellerId
  attr_accessor :idType
  attr_accessor :responseGroup

  def initialize(id = nil, sellerId = nil, idType = nil, responseGroup = [])
    @id = id
    @sellerId = sellerId
    @idType = idType
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}BrowseNodeLookupRequest
class BrowseNodeLookupRequest
  @@schema_type = "BrowseNodeLookupRequest"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["browseNodeId", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "BrowseNodeId")]],
    ["responseGroup", ["SOAP::SOAPString[]", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ResponseGroup")]]
  ]

  attr_accessor :browseNodeId
  attr_accessor :responseGroup

  def initialize(browseNodeId = [], responseGroup = [])
    @browseNodeId = browseNodeId
    @responseGroup = responseGroup
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}CartItem
class CartItem
  @@schema_type = "CartItem"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["cartItemId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CartItemId")]],
    ["aSIN", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ASIN")]],
    ["exchangeId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ExchangeId")]],
    ["merchantId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "MerchantId")]],
    ["sellerId", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerId")]],
    ["sellerNickname", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "SellerNickname")]],
    ["quantity", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Quantity")]],
    ["title", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Title")]],
    ["productGroup", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ProductGroup")]],
    ["listOwner", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListOwner")]],
    ["listType", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ListType")]],
    ["price", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Price")]],
    ["itemTotal", ["Price", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "ItemTotal")]]
  ]

  attr_accessor :cartItemId
  attr_accessor :aSIN
  attr_accessor :exchangeId
  attr_accessor :merchantId
  attr_accessor :sellerId
  attr_accessor :sellerNickname
  attr_accessor :quantity
  attr_accessor :title
  attr_accessor :productGroup
  attr_accessor :listOwner
  attr_accessor :listType
  attr_accessor :price
  attr_accessor :itemTotal

  def initialize(cartItemId = nil, aSIN = nil, exchangeId = nil, merchantId = nil, sellerId = nil, sellerNickname = nil, quantity = nil, title = nil, productGroup = nil, listOwner = nil, listType = nil, price = nil, itemTotal = nil)
    @cartItemId = cartItemId
    @aSIN = aSIN
    @exchangeId = exchangeId
    @merchantId = merchantId
    @sellerId = sellerId
    @sellerNickname = sellerNickname
    @quantity = quantity
    @title = title
    @productGroup = productGroup
    @listOwner = listOwner
    @listType = listType
    @price = price
    @itemTotal = itemTotal
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Address
class Address
  @@schema_type = "Address"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["name", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Name")]],
    ["address1", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Address1")]],
    ["address2", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Address2")]],
    ["address3", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Address3")]],
    ["city", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "City")]],
    ["state", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "State")]],
    ["postalCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "PostalCode")]],
    ["country", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Country")]]
  ]

  attr_accessor :name
  attr_accessor :address1
  attr_accessor :address2
  attr_accessor :address3
  attr_accessor :city
  attr_accessor :state
  attr_accessor :postalCode
  attr_accessor :country

  def initialize(name = nil, address1 = nil, address2 = nil, address3 = nil, city = nil, state = nil, postalCode = nil, country = nil)
    @name = name
    @address1 = address1
    @address2 = address2
    @address3 = address3
    @city = city
    @state = state
    @postalCode = postalCode
    @country = country
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Price
class Price
  @@schema_type = "Price"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["amount", ["SOAP::SOAPInteger", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Amount")]],
    ["currencyCode", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "CurrencyCode")]],
    ["formattedPrice", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "FormattedPrice")]]
  ]

  attr_accessor :amount
  attr_accessor :currencyCode
  attr_accessor :formattedPrice

  def initialize(amount = nil, currencyCode = nil, formattedPrice = nil)
    @amount = amount
    @currencyCode = currencyCode
    @formattedPrice = formattedPrice
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}Image
class Image
  @@schema_type = "Image"
  @@schema_ns = "http://webservices.amazon.com/AWSECommerceService/2006-06-07"
  @@schema_element = [
    ["uRL", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "URL")]],
    ["height", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Height")]],
    ["width", ["DecimalWithUnits", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "Width")]],
    ["isVerified", ["SOAP::SOAPString", XSD::QName.new("http://webservices.amazon.com/AWSECommerceService/2006-06-07", "IsVerified")]]
  ]

  attr_accessor :uRL
  attr_accessor :height
  attr_accessor :width
  attr_accessor :isVerified

  def initialize(uRL = nil, height = nil, width = nil, isVerified = nil)
    @uRL = uRL
    @height = height
    @width = width
    @isVerified = isVerified
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}NonNegativeIntegerWithUnits
#   contains SOAP::SOAPNonNegativeInteger
class NonNegativeIntegerWithUnits < ::String
  @@schema_attribute = {
    XSD::QName.new(nil, "Units") => "SOAP::SOAPString"
  }

  def xmlattr_Units
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")]
  end

  def xmlattr_Units=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}DecimalWithUnits
#   contains SOAP::SOAPDecimal
class DecimalWithUnits < ::String
  @@schema_attribute = {
    XSD::QName.new(nil, "Units") => "SOAP::SOAPString"
  }

  def xmlattr_Units
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")]
  end

  def xmlattr_Units=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {http://webservices.amazon.com/AWSECommerceService/2006-06-07}StringWithUnits
#   contains SOAP::SOAPString
class StringWithUnits < ::String
  @@schema_attribute = {
    XSD::QName.new(nil, "Units") => "SOAP::SOAPString"
  }

  def xmlattr_Units
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")]
  end

  def xmlattr_Units=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Units")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end
