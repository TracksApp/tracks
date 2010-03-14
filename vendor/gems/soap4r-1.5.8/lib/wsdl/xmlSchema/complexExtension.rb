# WSDL4R - XMLSchema complexType extension definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class ComplexExtension < Info
  attr_accessor :base
  attr_reader :content

  def initialize
    super
    @base = nil
    @basetype = nil
    @content = nil
    @attributes = XSD::NamedElements.new
  end

  def targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def have_any?
    basetype.have_any? or (content && content.have_any?)
  end

  def choice?
    content and content.choice?
  end

  def elements
    result = XSD::NamedElements.new
    result.concat(basetype.elements)
    result.concat(content.elements) if content
    result
  end

  def nested_elements
    result = XSD::NamedElements.new
    result.concat(basetype.nested_elements)
    result.concat(content.nested_elements) if content
    result
  end

  def attributes
    basetype.attributes + @attributes
  end

  def check_type
    if @base == ::SOAP::ValueArrayName
      :TYPE_ARRAY
    elsif content or !@attributes.empty?
      :TYPE_STRUCT
    else
      basetype.check_type
    end
  end
  
  def parse_element(element)
    case element
    when AllName
      @content = All.new
      @content
    when SequenceName
      @content = Sequence.new
      @content
    when ChoiceName
      @content = Choice.new
      @content
    when AttributeName
      o = Attribute.new
      @attributes << o
      o
    when AttributeGroupName
      o = AttributeGroup.new
      @attributes << o
      o
    when AnyAttributeName
      o = AnyAttribute.new
      @attributes << o
      o
    end
  end

  def parse_attr(attr, value)
    case attr
    when BaseAttrName
      @base = value
    end
  end

private

  def basetype
    @basetype ||= root.collect_complextypes[@base]
    unless @basetype
      raise RuntimeError.new("base type definition not found: #{@base}")
    end
    @basetype
  end
end


end
end
