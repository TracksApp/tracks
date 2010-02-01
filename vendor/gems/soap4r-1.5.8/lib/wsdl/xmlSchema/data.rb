# WSDL4R - XMLSchema data definitions.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/datatypes'
require 'wsdl/xmlSchema/annotation'
require 'wsdl/xmlSchema/schema'
require 'wsdl/xmlSchema/import'
require 'wsdl/xmlSchema/include'
require 'wsdl/xmlSchema/simpleType'
require 'wsdl/xmlSchema/simpleRestriction'
require 'wsdl/xmlSchema/simpleExtension'
require 'wsdl/xmlSchema/complexType'
require 'wsdl/xmlSchema/complexContent'
require 'wsdl/xmlSchema/complexRestriction'
require 'wsdl/xmlSchema/complexExtension'
require 'wsdl/xmlSchema/simpleContent'
require 'wsdl/xmlSchema/any'
require 'wsdl/xmlSchema/anyAttribute'
require 'wsdl/xmlSchema/element'
require 'wsdl/xmlSchema/all'
require 'wsdl/xmlSchema/choice'
require 'wsdl/xmlSchema/sequence'
require 'wsdl/xmlSchema/list'
require 'wsdl/xmlSchema/attribute'
require 'wsdl/xmlSchema/union'
require 'wsdl/xmlSchema/unique'
require 'wsdl/xmlSchema/group'
require 'wsdl/xmlSchema/attributeGroup'

require 'wsdl/xmlSchema/length'
require 'wsdl/xmlSchema/minlength'
require 'wsdl/xmlSchema/maxlength'
require 'wsdl/xmlSchema/pattern'
require 'wsdl/xmlSchema/enumeration'
require 'wsdl/xmlSchema/whitespace'
require 'wsdl/xmlSchema/maxinclusive'
require 'wsdl/xmlSchema/maxexclusive'
require 'wsdl/xmlSchema/minexclusive'
require 'wsdl/xmlSchema/mininclusive'
require 'wsdl/xmlSchema/totaldigits'
require 'wsdl/xmlSchema/fractiondigits'

module WSDL
module XMLSchema


AllName = XSD::QName.new(XSD::Namespace, 'all')
AnnotationName = XSD::QName.new(XSD::Namespace, 'annotation')
AnyName = XSD::QName.new(XSD::Namespace, 'any')
AnyAttributeName = XSD::QName.new(XSD::Namespace, 'anyAttribute')
AttributeName = XSD::QName.new(XSD::Namespace, 'attribute')
AttributeGroupName = XSD::QName.new(XSD::Namespace, 'attributeGroup')
ChoiceName = XSD::QName.new(XSD::Namespace, 'choice')
ComplexContentName = XSD::QName.new(XSD::Namespace, 'complexContent')
ComplexTypeName = XSD::QName.new(XSD::Namespace, 'complexType')
ElementName = XSD::QName.new(XSD::Namespace, 'element')
ExtensionName = XSD::QName.new(XSD::Namespace, 'extension')
GroupName = XSD::QName.new(XSD::Namespace, 'group')
ImportName = XSD::QName.new(XSD::Namespace, 'import')
IncludeName = XSD::QName.new(XSD::Namespace, 'include')
ListName = XSD::QName.new(XSD::Namespace, 'list')
RestrictionName = XSD::QName.new(XSD::Namespace, 'restriction')
SequenceName = XSD::QName.new(XSD::Namespace, 'sequence')
SchemaName = XSD::QName.new(XSD::Namespace, 'schema')
SimpleContentName = XSD::QName.new(XSD::Namespace, 'simpleContent')
SimpleTypeName = XSD::QName.new(XSD::Namespace, 'simpleType')
UnionName = XSD::QName.new(XSD::Namespace, 'union')
UniqueName = XSD::QName.new(XSD::Namespace, 'unique')

LengthName = XSD::QName.new(XSD::Namespace, 'length')
MinLengthName = XSD::QName.new(XSD::Namespace, 'minLength')
MaxLengthName = XSD::QName.new(XSD::Namespace, 'maxLength')
PatternName = XSD::QName.new(XSD::Namespace, 'pattern')
EnumerationName = XSD::QName.new(XSD::Namespace, 'enumeration')
WhiteSpaceName = XSD::QName.new(XSD::Namespace, 'whiteSpace')
MaxInclusiveName = XSD::QName.new(XSD::Namespace, 'maxInclusive')
MaxExclusiveName = XSD::QName.new(XSD::Namespace, 'maxExclusive')
MinExclusiveName = XSD::QName.new(XSD::Namespace, 'minExclusive')
MinInclusiveName = XSD::QName.new(XSD::Namespace, 'minInclusive')
TotalDigitsName = XSD::QName.new(XSD::Namespace, 'totalDigits')
FractionDigitsName = XSD::QName.new(XSD::Namespace, 'fractionDigits')

AbstractAttrName = XSD::QName.new(nil, 'abstract')
AttributeFormDefaultAttrName = XSD::QName.new(nil, 'attributeFormDefault')
BaseAttrName = XSD::QName.new(nil, 'base')
DefaultAttrName = XSD::QName.new(nil, 'default')
ElementFormDefaultAttrName = XSD::QName.new(nil, 'elementFormDefault')
FinalAttrName = XSD::QName.new(nil, 'final')
FixedAttrName = XSD::QName.new(nil, 'fixed')
FormAttrName = XSD::QName.new(nil, 'form')
IdAttrName = XSD::QName.new(nil, 'id')
ItemTypeAttrName = XSD::QName.new(nil, 'itemType')
MaxOccursAttrName = XSD::QName.new(nil, 'maxOccurs')
MemberTypesAttrName = XSD::QName.new(nil, 'memberTypes')
MinOccursAttrName = XSD::QName.new(nil, 'minOccurs')
MixedAttrName = XSD::QName.new(nil, 'mixed')
NameAttrName = XSD::QName.new(nil, 'name')
NamespaceAttrName = XSD::QName.new(nil, 'namespace')
NillableAttrName = XSD::QName.new(nil, 'nillable')
ProcessContentsAttrName = XSD::QName.new(nil, 'processContents')
RefAttrName = XSD::QName.new(nil, 'ref')
SchemaLocationAttrName = XSD::QName.new(nil, 'schemaLocation')
TargetNamespaceAttrName = XSD::QName.new(nil, 'targetNamespace')
TypeAttrName = XSD::QName.new(nil, 'type')
UseAttrName = XSD::QName.new(nil, 'use')
ValueAttrName = XSD::QName.new(nil, 'value')
VersionAttrName = XSD::QName.new(nil, 'version')


end
end
