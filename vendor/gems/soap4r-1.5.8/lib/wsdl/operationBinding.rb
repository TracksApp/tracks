# WSDL4R - WSDL bound operation definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL


class OperationBinding < Info
  attr_reader :name		# required
  attr_reader :input
  attr_reader :output
  attr_reader :fault
  attr_reader :soapoperation

  class OperationInfo
    attr_reader :boundid
    attr_reader :qname
    attr_reader :style
    attr_accessor :inputuse
    attr_accessor :outputuse
    attr_reader :parts
    attr_reader :faults

    def initialize(boundid, qname, style, inputuse, outputuse)
      @boundid = boundid
      @qname = qname
      @style = style
      @inputuse = inputuse
      @outputuse = outputuse
      @parts = []
      @faults = {}
    end
  end

  class Part
    attr_reader :io_type
    attr_reader :name
    attr_reader :type
    attr_reader :element

    def initialize(io_type, name, type, element)
      @io_type = io_type
      @name = name
      @type = type
      @element = element
    end
  end

  class BoundId
    attr_reader :name
    attr_reader :soapaction

    def initialize(name, soapaction)
      @name = name
      @soapaction = soapaction
    end

    def ==(rhs)
      !rhs.nil? and @name == rhs.name and @soapaction == rhs.soapaction
    end

    def eql?(rhs)
      (self == rhs)
    end

    def hash
      @name.hash ^ @soapaction.hash
    end
  end

  def initialize
    super
    @name = nil
    @input = nil
    @output = nil
    @fault = []
    @soapoperation = nil
  end

  def operation_info
    qname = soapoperation_name()
    style = soapoperation_style()
    use_input = soapbody_use(@input)
    use_output = soapbody_use(@output)
    info = OperationInfo.new(boundid, qname, style, use_input, use_output)
    op = find_operation()
    if style == :rpc
      info.parts.concat(collect_rpcparameter(op))
    else
      info.parts.concat(collect_documentparameter(op))
    end
    @fault.each do |fault|
      op_fault = {}
      soapfault = fault.soapfault
      next if soapfault.nil?
      op_fault[:ns] = fault.name.namespace
      op_fault[:name] = fault.name.name
      op_fault[:namespace] = soapfault.namespace
      op_fault[:use] = soapfault.use || "literal"
      op_fault[:encodingstyle] = soapfault.encodingstyle || "document"
      info.faults[fault.name] = op_fault
    end
    info
  end

  def targetnamespace
    parent.targetnamespace
  end

  def porttype
    root.porttype(parent.type)
  end

  def boundid
    BoundId.new(name, soapaction)
  end

  def find_operation
    porttype.operations.each do |op|
      next if op.name != @name
      next if op.input and @input and op.input.name and @input.name and
        op.input.name != @input.name
      next if op.output and @output and op.output.name and @output.name and
        op.output.name != @output.name
      return op
    end
    raise RuntimeError.new("#{@name} not found")
  end

  def soapoperation_name
    op_name = find_operation.operationname
    if @input and @input.soapbody and @input.soapbody.namespace
      op_name = XSD::QName.new(@input.soapbody.namespace, op_name.name)
    end
    op_name
  end

  def soapoperation_style
    style = nil
    if @soapoperation
      style = @soapoperation.operation_style
    elsif parent.soapbinding
      style = parent.soapbinding.style
    else
      raise TypeError.new("operation style definition not found")
    end
    style || :document
  end

  def soapaction
    if @soapoperation
      @soapoperation.soapaction
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
    when SOAPOperationName
      o = WSDL::SOAP::Operation.new
      @soapoperation = o
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
    else
      nil
    end
  end

private

  def soapbody_use(param)
    param ? param.soapbody_use : nil
  end

  def collect_rpcparameter(operation)
    result = operation.inputparts.collect { |part|
      Part.new(:in, part.name, part.type, part.element)
    }
    outparts = operation.outputparts
    if outparts.size > 0
      retval = outparts[0]
      result << Part.new(:retval, retval.name, retval.type, retval.element)
      cdr(outparts).each { |part|
	result << Part.new(:out, part.name, part.type, part.element)
      }
    end
    result
  end

  def collect_documentparameter(operation)
    param = []
    operation.inputparts.each do |input|
      param << Part.new(:in, input.name, input.type, input.element)
    end
    operation.outputparts.each do |output|
      param << Part.new(:out, output.name, output.type, output.element)
    end
    param
  end

  def cdr(ary)
    result = ary.dup
    result.shift
    result
  end
end


end
