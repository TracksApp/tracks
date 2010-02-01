require 'echo.rb'
require 'soap/mapping'

module WSDL; module Group

module EchoMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsGrouptype = "urn:grouptype"
  NsXMLSchema = "http://www.w3.org/2001/XMLSchema"

  EncodedRegistry.register(
    :class => WSDL::Group::Groupele_type,
    :schema_type => XSD::QName.new(NsGrouptype, "groupele_type"),
    :schema_element => [
      ["comment", "SOAP::SOAPString", [0, 1]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      [ :choice,
        ["element", ["SOAP::SOAPString", XSD::QName.new(nil, "element")]],
        ["eletype", ["SOAP::SOAPString", XSD::QName.new(nil, "eletype")]]
      ],
      ["var", ["SOAP::SOAPString", XSD::QName.new(nil, "var")]]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "attr_min") => "SOAP::SOAPDecimal",
      XSD::QName.new(nil, "attr_max") => "SOAP::SOAPDecimal"
    }
  )

  LiteralRegistry.register(
    :class => WSDL::Group::Groupele_type,
    :schema_type => XSD::QName.new(NsGrouptype, "groupele_type"),
    :schema_element => [
      ["comment", "SOAP::SOAPString", [0, 1]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      [ :choice,
        ["element", ["SOAP::SOAPString", XSD::QName.new(nil, "element")]],
        ["eletype", ["SOAP::SOAPString", XSD::QName.new(nil, "eletype")]]
      ],
      ["var", ["SOAP::SOAPString", XSD::QName.new(nil, "var")]]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "attr_min") => "SOAP::SOAPDecimal",
      XSD::QName.new(nil, "attr_max") => "SOAP::SOAPDecimal"
    }
  )

  LiteralRegistry.register(
    :class => WSDL::Group::Groupele_type,
    :schema_name => XSD::QName.new(NsGrouptype, "groupele"),
    :schema_element => [
      ["comment", "SOAP::SOAPString", [0, 1]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      [ :choice,
        ["element", ["SOAP::SOAPString", XSD::QName.new(nil, "element")]],
        ["eletype", ["SOAP::SOAPString", XSD::QName.new(nil, "eletype")]]
      ],
      ["var", ["SOAP::SOAPString", XSD::QName.new(nil, "var")]]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "attr_min") => "SOAP::SOAPDecimal",
      XSD::QName.new(nil, "attr_max") => "SOAP::SOAPDecimal"
    }
  )
end

end; end
