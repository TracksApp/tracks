# WSDL4R - WSDL operation definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL


class Operation < Info
  class NameInfo
    attr_reader :op_name
    attr_reader :optype_name
    attr_reader :parts
    def initialize(op_name, optype_name, parts)
      @op_name = op_name
      @optype_name = optype_name
      @parts = parts
    end
  end

  attr_reader :name		# required
  attr_reader :parameter_order	# optional
  attr_reader :input
  attr_reader :output
  attr_reader :fault
  attr_reader :type		# required

  def initialize
    super
    @name = nil
    @type = nil
    @parameter_order = nil
    @input = nil
    @output = nil
    @fault = []
  end

  def targetnamespace
    parent.targetnamespace
  end

  def operationname
    as_operationname(@name)
  end

  def input_info
    if message = input_message
      typename = message.name
    else
      typename = nil
    end
    NameInfo.new(operationname, typename, inputparts)
  end

  def output_info
    if message = output_message
      typename = message.name
    else
      typename = nil
    end
    NameInfo.new(operationname, typename, outputparts)
  end

  EMPTY = [].freeze
  def inputparts
    if message = input_message
      sort_parts(message.parts)
    else
      EMPTY
    end
  end

  def inputname
    if input
      as_operationname(input.name ? input.name.name : @name)
    else
      nil
    end
  end

  def outputparts
    if message = output_message
      sort_parts(message.parts)
    else
      EMPTY
    end
  end

  def outputname
    if output
      as_operationname(output.name ? output.name.name : @name + 'Response')
    else
      nil
    end
  end

  def parse_element(element)
    case element
    when InputName
      o = Param.new
      @input = o
      o
    when OutputName
      o = Param.new
      @output = o
      o
    when FaultName
      o = Param.new
      @fault << o
      o
    when DocumentationName
      o = Documentation.new
      o
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = value.source
    when TypeAttrName
      @type = value
    when ParameterOrderAttrName
      @parameter_order = value.source.split(/\s+/)
    else
      nil
    end
  end

private

  def input_message
    if input and message = input.find_message
      message
    else
      nil
    end
  end

  def output_message
    if output and message = output.find_message
      message
    else
      nil
    end
  end

  def sort_parts(parts)
    return parts.dup unless parameter_order
    result = []
    parameter_order.each do |orderitem|
      if (ele = parts.find { |part| part.name == orderitem })
	result << ele
      end
    end
    if result.length == 0
      return parts.dup
    end
    # result length can be shorter than parts's.
    # return part must not be a part of the parameterOrder.
    result
  end

  def as_operationname(name)
    XSD::QName.new(targetnamespace, name)
  end
end


end
