# WSDL4R - WSDL additional definitions for SOAP.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'
require 'soap/mapping'


module WSDL


class Definitions < Info
  def self.soap_rpc_complextypes
    types = XSD::NamedElements.new
    types << array_complextype
    types << fault_complextype
    types << exception_complextype
    types
  end

  def self.array_complextype
    type = XMLSchema::ComplexType.new(::SOAP::ValueArrayName)
    type.complexcontent = XMLSchema::ComplexContent.new
    type.complexcontent.restriction = XMLSchema::ComplexRestriction.new
    type.complexcontent.restriction.base = ::SOAP::ValueArrayName
    attr = XMLSchema::Attribute.new
    attr.ref = ::SOAP::AttrArrayTypeName
    anyarray = XSD::QName.new(
      XSD::AnyTypeName.namespace,
      XSD::AnyTypeName.name + '[]')
    attr.arytype = anyarray
    type.complexcontent.restriction.attributes << attr
    type
  end

=begin
<xs:complexType name="Fault" final="extension">
  <xs:sequence>
    <xs:element name="faultcode" type="xs:QName" /> 
    <xs:element name="faultstring" type="xs:string" /> 
    <xs:element name="faultactor" type="xs:anyURI" minOccurs="0" /> 
    <xs:element name="detail" type="tns:detail" minOccurs="0" /> 
  </xs:sequence>
</xs:complexType>
=end
  def self.fault_complextype
    type = XMLSchema::ComplexType.new(::SOAP::EleFaultName)
    faultcode = XMLSchema::Element.new(::SOAP::EleFaultCodeName, XSD::XSDQName::Type)
    faultstring = XMLSchema::Element.new(::SOAP::EleFaultStringName, XSD::XSDString::Type)
    faultactor = XMLSchema::Element.new(::SOAP::EleFaultActorName, XSD::XSDAnyURI::Type)
    faultactor.minoccurs = 0
    detail = XMLSchema::Element.new(::SOAP::EleFaultDetailName, XSD::AnyTypeName)
    detail.minoccurs = 0
    type.all_elements = [faultcode, faultstring, faultactor, detail]
    type.final = 'extension'
    type
  end

  def self.exception_complextype
    type = XMLSchema::ComplexType.new(XSD::QName.new(
	::SOAP::Mapping::RubyCustomTypeNamespace, 'SOAPException'))
    excn_name = XMLSchema::Element.new(XSD::QName.new(nil, 'excn_type_name'), XSD::XSDString::Type)
    cause = XMLSchema::Element.new(XSD::QName.new(nil, 'cause'), XSD::AnyTypeName)
    backtrace = XMLSchema::Element.new(XSD::QName.new(nil, 'backtrace'), ::SOAP::ValueArrayName)
    message = XMLSchema::Element.new(XSD::QName.new(nil, 'message'), XSD::XSDString::Type)
    type.all_elements = [excn_name, cause, backtrace, message]
    type
  end

  def soap_rpc_complextypes(binding)
    types = rpc_operation_complextypes(binding)
    types + self.class.soap_rpc_complextypes
  end

  def collect_faulttypes
    result = []
    collect_fault_messages.each do |name|
      faultparts = message(name).parts
      if faultparts.size != 1
	raise RuntimeError.new("Expecting fault message \"#{name}\" to have ONE part")
      end
      fault_part = faultparts[0]
      # WS-I Basic Profile Version 1.1 (R2205) requires fault message parts 
      # to refer to elements rather than types
      faulttype = fault_part.element
      if not faulttype
	warn("Fault message \"#{name}\" part \"#{fault_part.name}\" must specify an \"element\" attribute")
        faulttype = fault_part.type
      end
      if faulttype and result.index(faulttype).nil?
	result << faulttype
      end
    end
    result
  end

private

  def get_fault_binding(op_binding, fault_name)
    op_binding.fault.each do |fault|
      return fault if fault.name == fault_name
    end
    return nil
  end

  def op_binding_declares_fault(op_binding, fault_name)
    return get_fault_binding(op_binding, fault_name) != nil
  end

  def collect_fault_messages
    result = []
    porttypes.each do |porttype|
      port_binding = porttype.find_binding()
      next unless port_binding
      porttype.operations.each do |operation|
        op_binding = port_binding.operations.find { |ele| ele.name == operation.name }
        next unless op_binding
	operation.fault.each do |fault|
          # Make sure the operation fault has a name
          if not fault.name
            warn("Operation \"#{operation.name}\": fault must specify a \"name\" attribute")
            next
          end
          # Make sure that portType fault has a corresponding soap:fault
          # definition in binding section.
          if not op_binding_declares_fault(op_binding, fault.name)
            warn("Operation \"#{operation.name}\", fault \"#{fault.name}\": no corresponding wsdl:fault binding found with a matching \"name\" attribute")          
            next
          end
          fault_binding = get_fault_binding(op_binding, fault.name)
          if fault_binding.soapfault.nil?
            warn("WARNING: no soap:fault found for wsdl:fault \"#{fault_binding.name}\" in operation \"#{operation.name}\" \n\n")
            next
          end
          if fault_binding.soapfault.name != fault_binding.name
            warn("WARNING: name of soap:fault \"#{fault_binding.soapfault.name}\" doesn't match the name of wsdl:fault \"#{fault_binding.name}\" in operation \"#{operation.name}\" \n\n")
            next
          end
          # According to WS-I (R2723): if in a wsdl:binding the use attribute
          # on a contained soapbind:fault element is present, its value MUST 
          # be "literal".          
          if fault_binding.soapfault.use and fault_binding.soapfault.use != "literal"
            warn("Operation \"#{operation.name}\", fault \"#{fault.name}\": soap:fault \"use\" attribute must be \"literal\"")          
          end
	  if result.index(fault.message).nil?
	    result << fault.message
	  end
	end
      end
    end
    result
  end

  def rpc_operation_complextypes(binding)
    types = XSD::NamedElements.new
    binding.operations.each do |op_bind|
      if op_bind_rpc?(op_bind)
	operation = op_bind.find_operation
	if op_bind.input
	  type = XMLSchema::ComplexType.new(op_bind.soapoperation_name)
	  message = messages[operation.input.message]
	  type.sequence_elements = elements_from_message(message)
	  types << type
	end
	if op_bind.output
	  type = XMLSchema::ComplexType.new(operation.outputname)
	  message = messages[operation.output.message]
	  type.sequence_elements = elements_from_message(message)
	  types << type
	end
      end
    end
    types
  end

  def op_bind_rpc?(op_bind)
    op_bind.soapoperation_style == :rpc
  end

  def elements_from_message(message)
    message.parts.collect { |part|
      if part.element
        collect_elements[part.element]
      elsif part.name.nil? or part.type.nil?
	raise RuntimeError.new("part of a message must be an element or typed")
      else
        qname = XSD::QName.new(nil, part.name)
        XMLSchema::Element.new(qname, part.type)
      end
    }
  end
end


end
