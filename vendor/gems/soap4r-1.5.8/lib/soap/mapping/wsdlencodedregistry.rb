# SOAP4R - WSDL encoded mapping registry.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/qname'
require 'xsd/namedelements'
require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'


module SOAP
module Mapping


class WSDLEncodedRegistry < EncodedRegistry
  attr_reader :definedelements
  attr_reader :definedtypes

  def initialize(definedtypes = XSD::NamedElements::Empty)
    super()
    @definedtypes = definedtypes
    # @definedelements = definedelements  needed?
    # For mapping AnyType element.
    @rubytype_factory = RubytypeFactory.new(
      :allow_untyped_struct => true,
      :allow_original_mapping => true
    )
  end

  def obj2soap(obj, qname = nil)
    soap_obj = nil
    if type = @definedtypes[qname]
      soap_obj = obj2typesoap(obj, type)
    else
      soap_obj = any2soap(obj, qname)
    end
    return soap_obj if soap_obj
    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
      return soap_obj if soap_obj
    end
    if qname
      raise MappingError.new("cannot map #{obj.class.name} as #{qname}")
    else
      raise MappingError.new("cannot map #{obj.class.name} to SOAP/OM")
    end
  end

  # map anything for now: must refer WSDL while mapping.  [ToDo]
  def soap2obj(node, obj_class = nil)
    cause = nil
    begin
      unless obj_class
        typestr = Mapping.safeconstname(node.elename.name)
        obj_class = Mapping.class_from_name(typestr)
      end
      return Mapping._soap2obj(node, Mapping::DefaultRegistry, obj_class)
    rescue MappingError
      cause = $!
    end
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping._soap2obj(yield_node, self)
	  }
      rescue Exception
      end
    end
    raise MappingError.new("cannot map #{node.type.name} to Ruby object", cause)
  end

private

  def any2soap(obj, qname)
    ele = nil
    if obj.nil?
      ele = SOAPNil.new
    elsif qname.nil? or qname == XSD::AnyTypeName
      ele = @rubytype_factory.obj2soap(nil, obj, nil, self)
    elsif obj.is_a?(XSD::NSDBase)
      ele = soap2soap(obj, qname)
    elsif type = TypeMap[qname]
      ele = base2soap(obj, type)
    end
    add_attributes2soap(obj, ele) unless ele.nil?
    ele
  end

  def soap2soap(obj, type_qname)
    if obj.is_a?(SOAPBasetype)
      obj
    elsif obj.is_a?(SOAPStruct) && (type = @definedtypes[type_qname])
      soap_obj = obj
      mark_marshalled_obj(obj, soap_obj)
      elements2soap(obj, soap_obj, type.elements)
      soap_obj
    elsif obj.is_a?(SOAPArray) && (type = @definedtypes[type_qname])
      soap_obj = obj
      contenttype = type.child_type
      mark_marshalled_obj(obj, soap_obj)
      obj.replace do |ele|
	Mapping._obj2soap(ele, self, contenttype)
      end
      soap_obj
    else
      nil
    end
  end

  def obj2typesoap(obj, type)
    if type.is_a?(::WSDL::XMLSchema::SimpleType)
      simpleobj2soap(obj, type)
    else
      complexobj2soap(obj, type)
    end
  end

  def simpleobj2soap(obj, type)
    type.check_lexical_format(obj)
    return SOAPNil.new if obj.nil?      # TODO: check nillable.
    if type.base
      ele = base2soap(obj, TypeMap[type.base])
      ele.type = type.name
    elsif type.list
      value = obj.is_a?(Array) ? obj.join(" ") : obj.to_s
      ele = base2soap(value, SOAP::SOAPString)
    else
      raise MappingError.new("unsupported simpleType: #{type}")
    end
    ele
  end

  def complexobj2soap(obj, type)
    case type.compoundtype
    when :TYPE_STRUCT
      struct2soap(obj, type.name, type)
    when :TYPE_ARRAY
      array2soap(obj, type.name, type)
    when :TYPE_MAP
      map2soap(obj, type.name, type)
    when :TYPE_SIMPLE
      simpleobj2soap(obj, type.simplecontent)
    when :TYPE_EMPTY
      raise MappingError.new("should be empty") unless obj.nil?
      SOAPNil.new
    else
      raise MappingError.new("unknown compound type: #{type.compoundtype}")
    end
  end

  def struct2soap(obj, type_qname, type)
    return SOAPNil.new if obj.nil?      # ToDo: check nillable.
    soap_obj = SOAPStruct.new(type_qname)
    mark_marshalled_obj(obj, soap_obj)
    elements2soap(obj, soap_obj, type.elements)
    soap_obj
  end

  def array2soap(obj, type_qname, type)
    return SOAPNil.new if obj.nil?      # ToDo: check nillable.
    arytype = type.child_type
    soap_obj = SOAPArray.new(ValueArrayName, 1, arytype)
    unless obj.nil?
      mark_marshalled_obj(obj, soap_obj)
      obj.each do |item|
        soap_obj.add(Mapping._obj2soap(item, self, arytype))
      end
    end
    soap_obj
  end

  MapKeyName = XSD::QName.new(nil, "key")
  MapValueName = XSD::QName.new(nil, "value")
  def map2soap(obj, type_qname, type)
    return SOAPNil.new if obj.nil?      # ToDo: check nillable.
    keytype = type.child_type(MapKeyName) || XSD::AnyTypeName
    valuetype = type.child_type(MapValueName) || XSD::AnyTypeName
    soap_obj = SOAPStruct.new(MapQName)
    unless obj.nil?
      mark_marshalled_obj(obj, soap_obj)
      obj.each do |key, value|
        elem = SOAPStruct.new
        elem.add("key", Mapping._obj2soap(key, self, keytype))
        elem.add("value", Mapping._obj2soap(value, self, valuetype))
        # ApacheAxis allows only 'item' here.
        soap_obj.add("item", elem)
      end
    end
    soap_obj
  end

  def elements2soap(obj, soap_obj, elements)
    elements.each do |element|
      name = element.name.name
      child_obj = Mapping.get_attribute(obj, name)
      soap_obj.add(name,
        Mapping._obj2soap(child_obj, self, element.type || element.name))
    end
  end
end


end
end
