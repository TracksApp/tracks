# WSDL4R - XMLSchema group definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/xmlSchema/ref'


module WSDL
module XMLSchema


class Group < Info
  include Ref

  attr_writer :name	# required
  attr_accessor :maxoccurs
  attr_accessor :minoccurs
  attr_writer :content

  attr_reader_ref :name
  attr_reader_ref :content

  def initialize(name = nil)
    super()
    @name = name
    @maxoccurs = 1
    @minoccurs = 1
    @content = nil
    @ref = nil
    @refelement = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def parse_element(element)
    case element
    when AllName
      @content = All.new
    when SequenceName
      @content = Sequence.new
    when ChoiceName
      @content = Choice.new
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value.source)
    when RefAttrName
      @ref = value
    when MaxOccursAttrName
      if parent.is_a?(All)
	if value.source != '1'
	  raise Parser::AttributeConstraintError.new(
            "cannot parse #{value} for #{attr}")
	end
      end
      if value.source == 'unbounded'
        @maxoccurs = nil
      else
        @maxoccurs = Integer(value.source)
      end
      value.source
    when MinOccursAttrName
      if parent.is_a?(All)
	unless ['0', '1'].include?(value.source)
	  raise Parser::AttributeConstraintError.new(
            "cannot parse #{value} for #{attr}")
	end
      end
      @minoccurs = Integer(value.source)
    else
      nil
    end
  end

private

  def refelement
    @refelement ||= (@ref ? root.collect_modelgroups[@ref] : nil)
  end
end


end
end
