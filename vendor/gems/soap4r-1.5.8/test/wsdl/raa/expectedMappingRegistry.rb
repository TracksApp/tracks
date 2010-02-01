require 'RAA.rb'
require 'soap/mapping'

module WSDL; module RAA

module RAAMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsC_002 = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"

  EncodedRegistry.register(
    :class => WSDL::RAA::Category,
    :schema_type => XSD::QName.new(NsC_002, "Category"),
    :schema_element => [
      ["major", ["SOAP::SOAPString", XSD::QName.new(nil, "major")]],
      ["minor", ["SOAP::SOAPString", XSD::QName.new(nil, "minor")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::RAA::Product,
    :schema_type => XSD::QName.new(NsC_002, "Product"),
    :schema_element => [
      ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["short_description", ["SOAP::SOAPString", XSD::QName.new(nil, "short_description")]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")]],
      ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")]],
      ["homepage", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "homepage")]],
      ["download", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "download")]],
      ["license", ["SOAP::SOAPString", XSD::QName.new(nil, "license")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::RAA::Owner,
    :schema_type => XSD::QName.new(NsC_002, "Owner"),
    :schema_element => [
      ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
      ["email", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "email")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::RAA::Info,
    :schema_type => XSD::QName.new(NsC_002, "Info"),
    :schema_element => [
      ["category", ["WSDL::RAA::Category", XSD::QName.new(nil, "category")]],
      ["product", ["WSDL::RAA::Product", XSD::QName.new(nil, "product")]],
      ["owner", ["WSDL::RAA::Owner", XSD::QName.new(nil, "owner")]],
      ["created", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "created")]],
      ["updated", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "updated")]]
    ]
  )

  EncodedRegistry.set(
    WSDL::RAA::InfoArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new(NsC_002, "Info") }
  )

  EncodedRegistry.set(
    WSDL::RAA::StringArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )

  LiteralRegistry.register(
    :class => WSDL::RAA::Category,
    :schema_type => XSD::QName.new(NsC_002, "Category"),
    :schema_element => [
      ["major", ["SOAP::SOAPString", XSD::QName.new(nil, "major")]],
      ["minor", ["SOAP::SOAPString", XSD::QName.new(nil, "minor")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::RAA::Product,
    :schema_type => XSD::QName.new(NsC_002, "Product"),
    :schema_element => [
      ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["short_description", ["SOAP::SOAPString", XSD::QName.new(nil, "short_description")]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")]],
      ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")]],
      ["homepage", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "homepage")]],
      ["download", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "download")]],
      ["license", ["SOAP::SOAPString", XSD::QName.new(nil, "license")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::RAA::Owner,
    :schema_type => XSD::QName.new(NsC_002, "Owner"),
    :schema_element => [
      ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
      ["email", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "email")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::RAA::Info,
    :schema_type => XSD::QName.new(NsC_002, "Info"),
    :schema_element => [
      ["category", ["WSDL::RAA::Category", XSD::QName.new(nil, "category")]],
      ["product", ["WSDL::RAA::Product", XSD::QName.new(nil, "product")]],
      ["owner", ["WSDL::RAA::Owner", XSD::QName.new(nil, "owner")]],
      ["created", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "created")]],
      ["updated", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "updated")]]
    ]
  )

end

end; end
