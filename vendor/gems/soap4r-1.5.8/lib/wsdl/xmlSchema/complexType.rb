# WSDL4R - XMLSchema complexType definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/xmlSchema/element'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class ComplexType < Info
  attr_accessor :name
  attr_accessor :complexcontent
  attr_accessor :simplecontent
  attr_reader :content
  attr_accessor :final
  attr_accessor :mixed
  attr_accessor :abstract

  def initialize(name = nil)
    super()
    @name = name
    @complexcontent = nil
    @simplecontent = nil
    @content = nil
    @final = nil
    @mixed = false
    @abstract = false
    @attributes = XSD::NamedElements.new
  end

  def targetnamespace
    # inner elements can be qualified
    # parent.is_a?(WSDL::XMLSchema::Element) ? nil : parent.targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def have_any?
    if c = @complexcontent || @content
      c.have_any?
    else
      false
    end
  end

  def choice?
    if c = @complexcontent || @content
      c.choice?
    else
      false
    end
  end

  def base
    if c = @complexcontent || @simplecontent
      c.base
    end
  end

  def elements
    if c = @complexcontent || @content
      c.elements
    else
      XSD::NamedElements::Empty
    end
  end

  def attributes
    attrs = nil
    if @complexcontent
      attrs = @complexcontent.attributes + @attributes
    elsif @simplecontent
      attrs = @simplecontent.attributes + @attributes
    else
      attrs = @attributes
    end
    found = XSD::NamedElements.new
    attrs.each do |attr|
      case attr
      when Attribute
        found << attr
      when AttributeGroup
        if attr.attributes
          found.concat(attr.attributes)
        end
      when AnyAttribute
        # ignored
      else
        warn("unknown attribute: #{attr}")
      end
    end
    found
  end

  def nested_elements
    if c = @complexcontent || @content
      c.nested_elements
    else
      XSD::NamedElements::Empty
    end
  end

  def find_element(name)
    return nil if name.nil?
    elements.each do |element|
      return element if name == element.name
    end
    nil
  end

  def find_element_by_name(name)
    return nil if name.nil?
    elements.each do |element|
      return element if name == element.name.name
    end
    nil
  end

  def sequence_elements=(elements)
    @content = Sequence.new
    elements.each do |element|
      @content << element
    end
  end

  def all_elements=(elements)
    @content = All.new
    elements.each do |element|
      @content << element
    end
  end

  def parse_element(element)
    case element
    when AllName
      @content = All.new
    when SequenceName
      @content = Sequence.new
    when ChoiceName
      @content = Choice.new
    when GroupName
      @content = Group.new
    when ComplexContentName
      @complexcontent = ComplexContent.new
    when SimpleContentName
      @simplecontent = SimpleContent.new
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
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when AbstractAttrName
      @abstract = to_boolean(value)
    when FinalAttrName
      @final = value.source
    when MixedAttrName
      @mixed = to_boolean(value)
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value.source)
    else
      nil
    end
  end
end


end
end
