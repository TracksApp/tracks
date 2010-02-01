# SOAP4R - WSDL literal mapping registry.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/literalregistry'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'
require 'xsd/namedelements'


module SOAP
module Mapping


class WSDLLiteralRegistry < LiteralRegistry
  attr_reader :definedelements
  attr_reader :definedtypes

  def initialize(definedtypes = XSD::NamedElements::Empty,
      definedelements = XSD::NamedElements::Empty)
    super()
    @definedtypes = definedtypes
    @definedelements = definedelements
  end

  def obj2soap(obj, qname, obj_class = nil)
    soap_obj = nil
    if obj.is_a?(SOAPElement)
      soap_obj = obj
    elsif eledef = @definedelements[qname]
      soap_obj = obj2elesoap(obj, eledef)
    elsif type = @definedtypes[qname]
      soap_obj = obj2typesoap(obj, type)
    else
      soap_obj = any2soap(obj, qname, obj_class)
    end
    return soap_obj if soap_obj
    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping.obj2soap(yield_obj, nil, nil, MAPPING_OPT)
      }
      return soap_obj if soap_obj
    end
    raise MappingError.new("cannot map #{obj.class.name} as #{qname}")
  end

  # node should be a SOAPElement
  def soap2obj(node, obj_class = nil)
    cause = nil
    begin
      return any2obj(node, obj_class)
    rescue MappingError
      cause = $!
    end
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping.soap2obj(yield_node, nil, nil, MAPPING_OPT)
	  }
      rescue Exception
      end
    end
    if node.respond_to?(:type)
      raise MappingError.new("cannot map #{node.type.name} to Ruby object", cause)
    else
      raise MappingError.new("cannot map #{node.elename.name} to Ruby object", cause)
    end
  end

private

  def obj2elesoap(obj, eledef)
    ele = nil
    qualified = (eledef.elementform == 'qualified')
    if obj.is_a?(SOAPNil)
      ele = obj
    elsif eledef.type
      if type = @definedtypes[eledef.type]
        ele = obj2typesoap(obj, type)
      elsif type = TypeMap[eledef.type]
        ele = base2soap(obj, type)
      else
        raise MappingError.new("cannot find type #{eledef.type}")
      end
    elsif eledef.local_complextype
      ele = obj2typesoap(obj, eledef.local_complextype)
    elsif eledef.local_simpletype
      ele = obj2typesoap(obj, eledef.local_simpletype)
    else
      raise MappingError.new('illegal schema?')
    end
    ele.elename = eledef.name
    ele.qualified = qualified
    ele
  end

  def obj2typesoap(obj, type)
    ele = nil
    if type.is_a?(::WSDL::XMLSchema::SimpleType)
      ele = simpleobj2soap(obj, type)
    else # complexType
      if type.simplecontent
        ele = simpleobj2soap(obj, type.simplecontent)
      else
        ele = complexobj2soap(obj, type)
      end
      add_definedattributes2soap(obj, ele, type)
    end
    ele
  end

  def simpleobj2soap(obj, type)
    type.check_lexical_format(obj)
    return SOAPNil.new if obj.nil?
    if type.base
      ele = base2soap(obj, TypeMap[type.base])
    elsif type.list
      value = obj.is_a?(Array) ? obj.join(" ") : obj.to_s
      ele = base2soap(value, SOAP::SOAPString)
    else
      raise MappingError.new("unsupported simpleType: #{type}")
    end
    ele
  end

  def complexobj2soap(obj, type)
    ele = SOAPElement.new(type.name)
    complexobj2sequencesoap(obj, ele, type, type.choice?, type.choice?)
    ele
  end

  def complexobj2sequencesoap(obj, soap, type, nillable, is_choice)
    added = false
    type.elements.each do |child_ele|
      case child_ele
      when WSDL::XMLSchema::Any
        any = Mapping.get_attributes_for_any(obj)
        SOAPElement.from_objs(any).each do |child|
          soap.add(child)
        end
        ele_added = true
      when WSDL::XMLSchema::Element
        ele_added = complexobj2soapchildren(obj, soap, child_ele, nillable)
      when WSDL::XMLSchema::Sequence
        ele_added = complexobj2sequencesoap(obj, soap, child_ele, nillable, false)
      when WSDL::XMLSchema::Choice
        ele_added = complexobj2sequencesoap(obj, soap, child_ele, true, true)
      else
        raise MappingError.new("unknown type: #{child_ele}")
      end
      added = true if ele_added
      break if is_choice and ele_added
    end
    added
  end

  def complexobj2soapchildren(obj, soap, child_ele, nillable = false)
    if child_ele.map_as_array?
      complexobj2soapchildren_array(obj, soap, child_ele, nillable)
    else
      complexobj2soapchildren_single(obj, soap, child_ele, nillable)
    end
  end

  def complexobj2soapchildren_array(obj, soap, child_ele, nillable)
    child = Mapping.get_attribute(obj, child_ele.name.name)
    if child.nil? and obj.is_a?(::Array)
      child = obj
    end
    if child.nil?
      return false if nillable
      if child_soap = nil2soap(child_ele)
        soap.add(child_soap)
        return true
      else
        return false
      end
    end
    unless child.respond_to?(:each)
      return false
    end
    child.each do |item|
      if item.is_a?(SOAPElement)
        soap.add(item)
      else
        child_soap = obj2elesoap(item, child_ele)
        soap.add(child_soap)
      end
    end
    true
  end

  def complexobj2soapchildren_single(obj, soap, child_ele, nillable)
    child = Mapping.get_attribute(obj, child_ele.name.name)
    case child
    when NilClass
      return false if nillable
      if child_soap = nil2soap(child_ele)
        soap.add(child_soap)
        true
      else
        false
      end
    when SOAPElement
      soap.add(child)
      true
    else
      child_soap = obj2elesoap(child, child_ele)
      soap.add(child_soap)
      true
    end
  end

  def nil2soap(ele)
    if ele.nillable
      obj2elesoap(nil, ele)     # add an empty element
    elsif ele.minoccurs == 0
      nil       # intends no element
    else
      warn("nil not allowed: #{ele.name.name}")
      nil
    end
  end

  def add_definedattributes2soap(obj, ele, typedef)
    if typedef.attributes
      typedef.attributes.each do |at|
        value = get_xmlattr_value(obj, at.name)
        ele.extraattr[at.name] = value unless value.nil?
      end
    end
  end
end


end
end
