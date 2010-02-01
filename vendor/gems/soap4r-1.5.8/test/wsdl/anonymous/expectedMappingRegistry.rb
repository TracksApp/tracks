require 'lp.rb'
require 'soap/mapping'

module WSDL; module Anonymous

module LpMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsLp = "urn:lp"

  EncodedRegistry.register(
    :class => WSDL::Anonymous::Header,
    :schema_type => XSD::QName.new(NsLp, "Header"),
    :schema_element => [
      ["header3", ["SOAP::SOAPString", XSD::QName.new(nil, "Header3")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::Anonymous::ExtraInfo,
    :schema_type => XSD::QName.new(NsLp, "ExtraInfo"),
    :schema_element => [
      ["entry", ["WSDL::Anonymous::ExtraInfo::Entry[]", XSD::QName.new(nil, "Entry")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::Anonymous::ExtraInfo::Entry,
    :schema_name => XSD::QName.new(nil, "Entry"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["key", ["SOAP::SOAPString", XSD::QName.new(nil, "Key")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "Value")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_type => XSD::QName.new(NsLp, "loginResponse"),
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_name => XSD::QName.new(nil, "loginResult"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Header,
    :schema_type => XSD::QName.new(NsLp, "Header"),
    :schema_element => [
      ["header3", ["SOAP::SOAPString", XSD::QName.new(nil, "Header3")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::ExtraInfo,
    :schema_type => XSD::QName.new(NsLp, "ExtraInfo"),
    :schema_element => [
      ["entry", ["WSDL::Anonymous::ExtraInfo::Entry[]", XSD::QName.new(nil, "Entry")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::ExtraInfo::Entry,
    :schema_name => XSD::QName.new(nil, "Entry"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["key", ["SOAP::SOAPString", XSD::QName.new(nil, "Key")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "Value")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_type => XSD::QName.new(NsLp, "loginResponse"),
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_name => XSD::QName.new(nil, "loginResult"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Pack,
    :schema_name => XSD::QName.new(NsLp, "Pack"),
    :schema_element => [
      ["header", ["WSDL::Anonymous::Pack::Header", XSD::QName.new(nil, "Header")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Pack::Header,
    :schema_name => XSD::QName.new(nil, "Header"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["header1", ["SOAP::SOAPString", XSD::QName.new(nil, "Header1")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Envelope,
    :schema_name => XSD::QName.new(NsLp, "Envelope"),
    :schema_element => [
      ["header", ["WSDL::Anonymous::Envelope::Header", XSD::QName.new(nil, "Header")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Envelope::Header,
    :schema_name => XSD::QName.new(nil, "Header"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["header2", ["SOAP::SOAPString", XSD::QName.new(nil, "Header2")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Login,
    :schema_name => XSD::QName.new(NsLp, "login"),
    :schema_element => [
      ["loginRequest", ["WSDL::Anonymous::Login::LoginRequest", XSD::QName.new(nil, "loginRequest")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Login::LoginRequest,
    :schema_name => XSD::QName.new(nil, "loginRequest"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["username", "SOAP::SOAPString"],
      ["password", "SOAP::SOAPString"],
      ["timezone", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_name => XSD::QName.new(NsLp, "loginResponse"),
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_name => XSD::QName.new(nil, "loginResult"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )
end

end; end
