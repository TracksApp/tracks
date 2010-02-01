# WSDL4R - XMLSchema content base definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module XMLSchema


class Content < Info
  attr_reader :minoccurs
  attr_reader :maxoccurs
  attr_reader :elements

  def initialize
    super()
    @minoccurs = 1
    @maxoccurs = 1
    @elements = XSD::NamedElements.new
  end

  def targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def have_any?
    false
  end

  def choice?
    false
  end

  def map_as_array?
    maxoccurs.nil? or maxoccurs != 1
  end

  def nested_elements
    elements = XSD::NamedElements.new
    @elements.each do |ele|
      if ele.respond_to?(:nested_elements)
        elements.concat(ele.nested_elements)
      else
        elements << ele
      end
    end
    elements
  end

  def <<(element)
    @elements << element
  end

  def parse_element(element)
    case element
    when ElementName
      o = Element.new
      o.form = elementformdefault
      @elements << o
      o
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when MaxOccursAttrName
      if value.source == 'unbounded'
        @maxoccurs = nil
      else
        @maxoccurs = Integer(value.source)
      end
      value.source
    when MinOccursAttrName
      @minoccurs = Integer(value.source)
    else
      nil
    end
  end
end


end
end
