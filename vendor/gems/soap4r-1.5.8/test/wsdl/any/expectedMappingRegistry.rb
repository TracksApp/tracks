require 'echo.rb'
require 'soap/mapping'

module WSDL; module Any

module EchoMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsEchoType = "urn:example.com:echo-type"
  NsXMLSchema = "http://www.w3.org/2001/XMLSchema"

  EncodedRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_type => XSD::QName.new(NsEchoType, "foo.bar"),
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_type => XSD::QName.new(NsEchoType, "foo.bar"),
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_name => XSD::QName.new(NsEchoType, "foo.bar"),
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::SetOutputAndCompleteRequest,
    :schema_name => XSD::QName.new(NsEchoType, "setOutputAndCompleteRequest"),
    :schema_element => [
      ["taskId", ["SOAP::SOAPString", XSD::QName.new(nil, "taskId")]],
      ["data", ["WSDL::Any::SetOutputAndCompleteRequest::C_Data", XSD::QName.new(nil, "data")]],
      ["participantToken", ["SOAP::SOAPString", XSD::QName.new(nil, "participantToken")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::SetOutputAndCompleteRequest::C_Data,
    :schema_name => XSD::QName.new(nil, "data"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]]
    ]
  )
end

end; end
