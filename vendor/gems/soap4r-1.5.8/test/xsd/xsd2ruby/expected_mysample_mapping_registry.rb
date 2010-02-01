require 'xsd/mapping'
require 'mysample.rb'

module XSD; module XSD2Ruby

module MysampleMappingRegistry
  NsMysample = "urn:mysample"
  Registry = ::SOAP::Mapping::LiteralRegistry.new

  Registry.register(
    :class => XSD::XSD2Ruby::Question,
    :schema_type => XSD::QName.new(NsMysample, "question"),
    :schema_element => [
      ["something", ["SOAP::SOAPString", XSD::QName.new(nil, "something")]]
    ]
  )

  Registry.register(
    :class => XSD::XSD2Ruby::Section,
    :schema_type => XSD::QName.new(NsMysample, "section"),
    :schema_element => [
      ["sectionID", ["SOAP::SOAPInt", XSD::QName.new(nil, "sectionID")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["index", ["SOAP::SOAPInt", XSD::QName.new(nil, "index")]],
      ["firstQuestion", ["XSD::XSD2Ruby::Question", XSD::QName.new(nil, "firstQuestion")]]
    ]
  )

  Registry.register(
    :class => XSD::XSD2Ruby::SectionArray,
    :schema_type => XSD::QName.new(NsMysample, "sectionArray"),
    :schema_element => [
      ["element", ["XSD::XSD2Ruby::Section[]", XSD::QName.new(nil, "element")], [1, nil]]
    ]
  )

  Registry.register(
    :class => XSD::XSD2Ruby::SectionElement,
    :schema_name => XSD::QName.new(NsMysample, "sectionElement"),
    :schema_element => [
      ["sectionID", ["SOAP::SOAPInt", XSD::QName.new(nil, "sectionID")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["index", ["SOAP::SOAPInt", XSD::QName.new(nil, "index")]],
      ["firstQuestion", ["XSD::XSD2Ruby::Question", XSD::QName.new(nil, "firstQuestion")]]
    ]
  )
end

end; end
