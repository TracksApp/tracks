# WSDL4R - XMLSchema simpleType definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class SimpleType < Info
  attr_accessor :name
  attr_reader :restriction
  attr_reader :list
  attr_reader :union

  def check_lexical_format(value)
    if @restriction
      check_restriction(value)
    elsif @list
      # TODO: check
    elsif @union
      # TODO: check
    else
      raise ArgumentError.new("incomplete simpleType")
    end
  end

  def base
    if @restriction
      @restriction.base
    else
      nil
    end
  end

  def initialize(name = nil)
    super()
    @name = name
    @restriction = nil
    @list = nil
    @union = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    case element
    when RestrictionName
      @restriction = SimpleRestriction.new
      @restriction
    when ListName
      @list = List.new
      @list
    when UnionName
      @union = Union.new
      @union
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value.source)
    end
  end

private

  def check_restriction(value)
    unless @restriction.valid?(value)
      raise XSD::ValueSpaceError.new("#{@name}: cannot accept '#{value}'")
    end
  end
end


end
end
