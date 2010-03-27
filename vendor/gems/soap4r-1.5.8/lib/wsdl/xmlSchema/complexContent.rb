# WSDL4R - XMLSchema complexContent definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class ComplexContent < Info
  attr_accessor :restriction
  attr_accessor :extension
  attr_accessor :mixed

  def initialize
    super
    @restriction = nil
    @extension = nil
    @mixed = false
  end

  def targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def content
    @extension || @restriction
  end

  def base
    content ? content.base : nil
  end

  def have_any?
    content ? content.have_any? : nil
  end

  def choice?
    content ? content.choice? : nil
  end

  def elements
    content ? content.elements : XSD::NamedElements::Empty
  end

  def attributes
    content ? content.attributes : XSD::NamedElements::Empty
  end

  def nested_elements
    # restrict and extension does not have particle.
    content ? content.nested_elements : XSD::NamedElements::Empty
  end

  def check_type
    if content
      content.check_type
    else
      raise ArgumentError.new("incomplete complexContent")
    end
  end

  def parse_element(element)
    case element
    when RestrictionName
      raise ArgumentError.new("incomplete complexContent") if content
      @restriction = ComplexRestriction.new
    when ExtensionName
      raise ArgumentError.new("incomplete complexContent") if content
      @extension = ComplexExtension.new
    end
  end

  def parse_attr(attr, value)
    case attr
    when MixedAttrName
      @mixed = to_boolean(value)
    else
      nil
    end
  end
end


end
end
