# WSDL4R - Creating driver code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/classDefCreatorSupport'
require 'soap/rpc/element'


module WSDL
module SOAP


class MethodDefCreator
  include ClassDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions, name_creator, modulepath, defined_const)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
    @simpletypes = @definitions.collect_simpletypes
    @complextypes = @definitions.collect_complextypes
    @elements = @definitions.collect_elements
    @types = []
    @encoded = false
    @literal = false
    @defined_const = defined_const
  end

  def dump(name)
    @types.clear
    @encoded = false
    @literal = false
    methoddef = ""
    porttype = @definitions.porttype(name)
    binding = porttype.find_binding
    if binding
      binding.operations.each do |op_bind|
        next unless op_bind # no binding is defined
        next unless op_bind.soapoperation # not a SOAP operation binding
        op = op_bind.find_operation
        methoddef << ",\n" unless methoddef.empty?
        methoddef << dump_method(op, op_bind).chomp
      end
    end
    result = {
      :methoddef => methoddef,
      :types => @types,
      :encoded => @encoded,
      :literal => @literal
    }
    result
  end

  def collect_rpcparameter(operation)
    result = operation.inputparts.collect { |part|
      collect_type(part.type)
      param_set(::SOAP::RPC::SOAPMethod::IN, part.name, rpcdefinedtype(part))
    }
    outparts = operation.outputparts
    if outparts.size > 0
      retval = outparts[0]
      collect_type(retval.type)
      result << param_set(::SOAP::RPC::SOAPMethod::RETVAL, retval.name,
        rpcdefinedtype(retval))
      cdr(outparts).each { |part|
	collect_type(part.type)
	result << param_set(::SOAP::RPC::SOAPMethod::OUT, part.name,
          rpcdefinedtype(part))
      }
    end
    result
  end

  def collect_documentparameter(operation)
    param = []
    operation.inputparts.each do |input|
      param << param_set(::SOAP::RPC::SOAPMethod::IN, input.name,
        documentdefinedtype(input))
    end
    operation.outputparts.each do |output|
      param << param_set(::SOAP::RPC::SOAPMethod::OUT, output.name,
        documentdefinedtype(output))
    end
    param
  end

private

  def dump_method(operation, binding)
    op_faults = {}
    binding.fault.each do |fault|
      op_fault = {}
      soapfault = fault.soapfault
      next if soapfault.nil?
      faultclass = mapped_class_name(fault.name, @modulepath)
      op_fault[:ns] = fault.name.namespace
      op_fault[:name] = fault.name.name
      op_fault[:namespace] = soapfault.namespace
      op_fault[:use] = soapfault.use || "literal"
      op_fault[:encodingstyle] = soapfault.encodingstyle || "document"
      op_faults[faultclass] = op_fault
    end
    op_faults_str = op_faults.inspect

    name = safemethodname(operation.name)
    name_as = operation.name
    style = binding.soapoperation_style
    inputuse = binding.soapbody_use_input
    outputuse = binding.soapbody_use_output
    if style == :rpc
      qname = binding.soapoperation_name
      paramstr = param2str(collect_rpcparameter(operation))
    else
      qname = nil
      paramstr = param2str(collect_documentparameter(operation))
    end
    if paramstr.empty?
      paramstr = '[]'
    else
      paramstr = "[ " << paramstr.split(/\r?\n/).join("\n    ") << " ]"
    end
    definitions = <<__EOD__
#{ndq(binding.soapaction)},
  #{dq(name)},
  #{paramstr},
  { :request_style =>  #{nsym(style)}, :request_use =>  #{nsym(inputuse)},
    :response_style => #{nsym(style)}, :response_use => #{nsym(outputuse)},
    :faults => #{op_faults_str} }
__EOD__
    if inputuse == :encoded or outputuse == :encoded
      @encoded = true
    end
    if inputuse == :literal or outputuse == :literal
      @literal = true
    end
    if style == :rpc
      assign_const(qname.namespace, 'Ns')
      return <<__EOD__
[ #{dqname(qname)},
  #{definitions}]
__EOD__
    else
      return <<__EOD__
[ #{definitions}]
__EOD__
    end
  end

  def rpcdefinedtype(part)
    if mapped = basetype_mapped_class(part.type)
      ['::' + mapped.name]
    elsif definedtype = @simpletypes[part.type]
      [nil, definedtype.name.namespace, definedtype.name.name]
    elsif definedtype = @elements[part.element]
      [nil, part.element.namespace, part.element.name]
    elsif definedtype = @complextypes[part.type]
      case definedtype.compoundtype
      when :TYPE_STRUCT, :TYPE_EMPTY, :TYPE_ARRAY, :TYPE_SIMPLE
        type = mapped_class_name(part.type, @modulepath)
	[type, part.type.namespace, part.type.name]
      when :TYPE_MAP
	[Hash.name, part.type.namespace, part.type.name]
      else
	raise NotImplementedError.new("must not reach here: #{definedtype.compoundtype}")
      end
    elsif part.type == XSD::AnyTypeName
      [nil]
    else
      raise RuntimeError.new("part: #{part.name} cannot be resolved")
    end
  end

  def documentdefinedtype(part)
    if mapped = basetype_mapped_class(part.type)
      ['::' + mapped.name, nil, part.name]
    elsif definedtype = @simpletypes[part.type]
      if definedtype.base
        ['::' + basetype_mapped_class(definedtype.base).name, nil, part.name]
      else
        raise RuntimeError.new("unsupported simpleType: #{definedtype}")
      end
    elsif definedtype = @elements[part.element]
      ['::SOAP::SOAPElement', part.element.namespace, part.element.name]
    elsif definedtype = @complextypes[part.type]
      ['::SOAP::SOAPElement', part.type.namespace, part.type.name]
    else
      raise RuntimeError.new("part: #{part.name} cannot be resolved")
    end
  end

  def param_set(io_type, name, type, ele = nil)
    [io_type, name, type, ele]
  end

  def collect_type(type)
    # ignore inline type definition.
    return if type.nil?
    return if @types.include?(type)
    @types << type
    return unless @complextypes[type]
    collect_elements_type(@complextypes[type].elements)
  end

  def collect_elements_type(elements)
    elements.each do |element|
      case element
      when WSDL::XMLSchema::Any
        # nothing to do
      when WSDL::XMLSchema::Element
        collect_type(element.type)
      when WSDL::XMLSchema::Sequence, WSDL::XMLSchema::Choice
        collect_elements_type(element.elements)
      else
        raise RuntimeError.new("unknown type: #{element}")
      end
    end
  end

  def param2str(params)
    params.collect { |param|
      io, name, type, ele = param
      unless ele.nil?
        "[#{dq(io)}, #{dq(name)}, #{type2str(type)}, #{ele2str(ele)}]"
      else
        "[#{dq(io)}, #{dq(name)}, #{type2str(type)}]"
      end
    }.join(",\n")
  end

  def type2str(type)
    if type.size == 1
      "[#{ndq(type[0])}]"
    else
      "[#{ndq(type[0])}, #{ndq(type[1])}, #{dq(type[2])}]"
    end
  end

  def ele2str(ele)
    qualified = ele
    if qualified
      "true"
    else
      "false"
    end
  end

  def cdr(ary)
    result = ary.dup
    result.shift
    result
  end
end


end
end
