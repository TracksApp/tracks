# WSDL4R - SOAP complexType definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/xmlSchema/complexType'
require 'soap/mapping'


module WSDL
module XMLSchema


class ComplexType < Info
  def compoundtype
    @compoundtype ||= check_type
  end

  def check_type
    if have_any?
      :TYPE_STRUCT
    elsif content
      if attributes.empty? and map_as_array?
        if name == ::SOAP::Mapping::MapQName
          :TYPE_MAP
        else
          :TYPE_ARRAY
        end
      else
	:TYPE_STRUCT
      end
    elsif complexcontent
      complexcontent.check_type
    elsif simplecontent
      :TYPE_SIMPLE
    elsif !attributes.empty?
      :TYPE_STRUCT
    else # empty complexType definition (seen in partner.wsdl of salesforce)
      :TYPE_EMPTY
    end
  end

  def child_type(name = nil)
    case compoundtype
    when :TYPE_STRUCT
      if ele = find_element(name)
        ele.type
      elsif ele = find_element_by_name(name.name)
	ele.type
      end
    when :TYPE_ARRAY
      @contenttype ||= content_arytype
    when :TYPE_MAP
      item_ele = find_element_by_name("item") or
        raise RuntimeError.new("'item' element not found in Map definition.")
      content = item_ele.local_complextype or
        raise RuntimeError.new("No complexType definition for 'item'.")
      if ele = content.find_element(name)
        ele.type
      elsif ele = content.find_element_by_name(name.name)
        ele.type
      end
    else
      raise NotImplementedError.new("Unknown kind of complexType.")
    end
  end

  def child_defined_complextype(name)
    ele = nil
    case compoundtype
    when :TYPE_STRUCT, :TYPE_MAP
      unless ele = find_element(name)
       	if name.namespace.nil?
  	  ele = find_element_by_name(name.name)
   	end
      end
    when :TYPE_ARRAY
      e = elements
      if e.size == 1
	ele = e[0]
      else
	raise RuntimeError.new("Assert: must not reach.")
      end
    else
      raise RuntimeError.new("Assert: Not implemented.")
    end
    unless ele
      raise RuntimeError.new("Cannot find #{name} as a children of #{@name}.")
    end
    ele.local_complextype
  end

  def find_soapenc_arytype
    unless compoundtype == :TYPE_ARRAY
      raise RuntimeError.new("Assert: not for array")
    end
    if complexcontent
      if complexcontent.restriction
        complexcontent.restriction.attributes.each do |attribute|
          if attribute.ref == ::SOAP::AttrArrayTypeName
            return attribute.arytype
          end
        end
      end
    end
    nil
  end

  def find_arytype
    unless compoundtype == :TYPE_ARRAY
      raise RuntimeError.new("Assert: not for array")
    end
    if arytype = find_soapenc_arytype
      return arytype
    end
    if map_as_array?
      return element_simpletype(elements[0])
    end
    raise RuntimeError.new("Assert: Unknown array definition.")
  end

  def find_aryelement
    unless compoundtype == :TYPE_ARRAY
      raise RuntimeError.new("Assert: not for array")
    end
    if map_as_array?
      return nested_elements[0]
    end
    nil # use default item name
  end

private

  def element_simpletype(element)
    case element
    when XMLSchema::Element
      if element.type
        element.type 
      elsif element.local_simpletype
        element.local_simpletype.base
      else
        # element definition
        nil
      end
    when XMLSchema::Any
      XSD::AnyTypeName
    else
      nil
    end
  end

  def map_as_array?
    e = nested_elements
    e.size == 1 and e[0].map_as_array?
  end

  def content_arytype
    if arytype = find_arytype
      ns = arytype.namespace
      name = arytype.name.sub(/\[(?:,)*\]$/, '')
      XSD::QName.new(ns, name)
    else
      nil
    end
  end
end


end
end
