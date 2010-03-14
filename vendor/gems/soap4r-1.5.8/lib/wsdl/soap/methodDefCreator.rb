# WSDL4R - Creating method definition from WSDL
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/classDefCreatorSupport'
require 'soap/rpc/element'
require 'soap/rpc/methodDef'


module WSDL
module SOAP


class MethodDefCreator
  include ClassDefCreatorSupport

  attr_reader :definitions
  # TODO: should not export this kind of stateful information.
  # will be rewwritten in 1.6.1
  attr_reader :assigned_method

  def initialize(definitions, name_creator, modulepath, defined_const)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
    @simpletypes = @definitions.collect_simpletypes
    @complextypes = @definitions.collect_complextypes
    @elements = @definitions.collect_elements
    @defined_const = defined_const
    @assigned_method = {}
  end

  def dump(name)
    methoddef = ""
    porttype = @definitions.porttype(name)
    binding = porttype.find_binding
    if binding
      create(binding.name).each do |mdef|
        methoddef << ",\n" unless methoddef.empty?
        methoddef << dump_method(mdef).chomp
      end
    end
    methoddef
  end

  def create(bindingname)
    binding = @definitions.binding(bindingname)
    if binding
      return binding.operations.collect { |op_bind|
        next unless op_bind.soapoperation # not a SOAP operation binding
        create_methoddef(op_bind)
      }
    end
    nil
  end

private

  def create_methoddef(op_bind)
    op_info = op_bind.operation_info
    name = assign_method_name(op_bind)
    soapaction = op_info.boundid.soapaction
    qname = op_bind.soapoperation_name
    mdef = ::SOAP::RPC::MethodDef.new(name, soapaction, qname)
    op_info.parts.each do |part|
      if op_info.style == :rpc
        mapped_class, qname = rpcdefinedtype(part)
      else
        mapped_class, qname = documentdefinedtype(part)
      end
      mdef.add_parameter(part.io_type, part.name, qname, mapped_class)
    end
    op_info.faults.each do |name, faultinfo|
      faultclass = mapped_class_name(name, @modulepath)
      mdef.faults[faultclass] = faultinfo
    end
    mdef.style = op_info.style
    mdef.inputuse = op_info.inputuse
    mdef.outputuse = op_info.outputuse
    mdef
  end

  def dump_method(mdef)
    style = mdef.style
    inputuse = mdef.inputuse
    outputuse = mdef.outputuse
    paramstr = param2str(mdef.parameters)
    if paramstr.empty?
      paramstr = '[]'
    else
      paramstr = "[ " << paramstr.split(/\r?\n/).join("\n    ") << " ]"
    end
    definitions = <<__EOD__
#{ndq(mdef.soapaction)},
  #{dq(mdef.name)},
  #{paramstr},
  { :request_style =>  #{nsym(style)}, :request_use =>  #{nsym(inputuse)},
    :response_style => #{nsym(style)}, :response_use => #{nsym(outputuse)},
    :faults => #{mdef.faults.inspect} }
__EOD__
    if style == :rpc
      assign_const(mdef.qname.namespace, 'Ns')
      return <<__EOD__
[ #{dqname(mdef.qname)},
  #{definitions}]
__EOD__
    else
      return <<__EOD__
[ #{definitions}]
__EOD__
    end
  end

  def assign_method_name(op_bind)
    method_name = safemethodname(op_bind.name)
    i = 1 # starts from _2
    while @assigned_method.value?(method_name)
      i += 1
      method_name = safemethodname("#{op_bind.name}_#{i}")
    end
    @assigned_method[op_bind.boundid] = method_name
    method_name
  end

  def rpcdefinedtype(part)
    if mapped = basetype_mapped_class(part.type)
      return ['::' + mapped.name, nil]
    elsif definedtype = @simpletypes[part.type]
      return [nil, definedtype.name]
    elsif definedtype = @elements[part.element]
      return [nil, part.element]
    elsif definedtype = @complextypes[part.type]
      case definedtype.compoundtype
      when :TYPE_STRUCT, :TYPE_EMPTY, :TYPE_ARRAY, :TYPE_SIMPLE
        type = mapped_class_name(part.type, @modulepath)
	return [type, part.type]
      when :TYPE_MAP
	return [Hash.name, part.type]
      else
	raise NotImplementedError.new("must not reach here: #{definedtype.compoundtype}")
      end
    elsif part.type == XSD::AnyTypeName
      return [nil, nil]
    else
      raise RuntimeError.new("part: #{part.name} cannot be resolved")
    end
  end

  def documentdefinedtype(part)
    if mapped = basetype_mapped_class(part.type)
      return ['::' + mapped.name, XSD::QName.new(nil, part.name)]
    elsif definedtype = @simpletypes[part.type]
      if definedtype.base
        return ['::' + basetype_mapped_class(definedtype.base).name, XSD::QName.new(nil, part.name)]
      else
        raise RuntimeError.new("unsupported simpleType: #{definedtype}")
      end
    elsif definedtype = @elements[part.element]
      return ['::SOAP::SOAPElement', part.element]
    elsif definedtype = @complextypes[part.type]
      return ['::SOAP::SOAPElement', part.type]
    else
      raise RuntimeError.new("part: #{part.name} cannot be resolved")
    end
  end

  def param2str(params)
    params.collect { |param|
      mappingstr = mapping_info2str(param.mapped_class, param.qname)
      "[:#{param.io_type.id2name}, #{dq(param.name)}, #{mappingstr}]"
    }.join(",\n")
  end

  def mapping_info2str(mapped_class, qname)
    if qname.nil?
      "[#{ndq(mapped_class)}]" 
    else
      "[#{ndq(mapped_class)}, #{ndq(qname.namespace)}, #{dq(qname.name)}]" 
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
end


end
end
