# WSDL4R - Creating class code support from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'soap/mapping'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'


module WSDL
module SOAP


# requires @defined_const, @simpletypes, @name_creator
module ClassDefCreatorSupport
  include XSD::CodeGen::GenSupport

  def mapped_class_name(qname, modulepath)
    @name_creator.assign_name(qname, modulepath)
  end

  def mapped_class_basename(qname, modulepath)
    classname = @name_creator.assign_name(qname, modulepath)
    classname.sub(/\A.*:/, '')
  end

  def basetype_mapped_class(name)
    ::SOAP::TypeMap[name]
  end

  def dump_method_signature(name, operation, element_definitions)
    methodname = safemethodname(name)
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{methodname}#{dump_inputparam(input)}"
    str = <<__EOD__
# SYNOPSIS
#   #{methodname}#{dump_inputparam(input)}
#
# ARGS
#{dump_inout_type(input, element_definitions).chomp}
#
# RETURNS
#{dump_inout_type(output, element_definitions).chomp}
#
__EOD__
    unless fault.empty?
      str <<<<__EOD__
# RAISES
#{dump_fault_type(fault, element_definitions)}
#
__EOD__
    end
    str
  end

  def dq(ele)
    ele.dump
  end

  def ndq(ele)
    ele.nil? ? 'nil' : dq(ele)
  end

  def sym(ele)
    ':' + ele.id2name
  end

  def nsym(ele)
    ele.nil? ? 'nil' : sym(ele)
  end

  def dqname(qname)
    if @defined_const.key?(qname.namespace)
      qname.dump(@defined_const[qname.namespace])
    else
      qname.dump
    end
  end

  def assign_const(value, prefix = '')
    return if value.nil? or @defined_const.key?(value)
    name = value.scan(/[^:\/]+\/?\z/)[0] || 'C'
    tag = prefix + safeconstname(name)
    if @defined_const.value?(tag)
      idx = 0
      while true
        tag = prefix + safeconstname(name + "_#{idx}")
        break unless @defined_const.value?(tag)
        idx += 1
        raise RuntimeError.new("too much similar names") if idx > 100
      end
    end
    @defined_const[value] = tag
  end

  def create_type_name(modulepath, element)
    if element.type == XSD::AnyTypeName
      # nil means anyType.
      nil
    elsif simpletype = @simpletypes[element.type]
      if simpletype.restriction and simpletype.restriction.enumeration?
        mapped_class_name(element.type, modulepath)
      else
        nil
      end
    elsif klass = element_basetype(element)
      klass.name
    elsif element.type
      mapped_class_name(element.type, modulepath)
    elsif element.ref
      mapped_class_name(element.ref, modulepath)
    elsif element.anonymous_type?
      # inner class
      mapped_class_name(element.name, modulepath)
    else
      nil
    end
  end

private

  def dump_inout_type(param, element_definitions)
    if param
      message = param.find_message
      params = ""
      message.parts.each do |part|
        name = safevarname(part.name)
        if part.type
          typename = safeconstname(part.type.name)
          qname = part.type
          params << add_at("#   #{name}", "#{typename} - #{qname}\n", 20)
        elsif part.element
          ele = element_definitions[part.element]
          if ele.type
            typename = safeconstname(ele.type.name)
            qname = ele.type
          else
            typename = safeconstname(ele.name.name)
            qname = ele.name
          end
          params << add_at("#   #{name}", "#{typename} - #{qname}\n", 20)
        end
      end
      unless params.empty?
        return params
      end
    end
    "#   N/A\n"
  end

  def dump_inputparam(input)
    message = input.find_message
    params = ""
    message.parts.each do |part|
      params << ", " unless params.empty?
      params << safevarname(part.name)
    end
    if params.empty?
      ""
    else
      "(#{ params })"
    end
  end

  def add_at(base, str, pos)
    if base.size >= pos
      base + ' ' + str
    else
      base + ' ' * (pos - base.size) + str
    end
  end

  def dump_fault_type(fault, element_definitions)
    fault.collect { |ele|
      dump_inout_type(ele, element_definitions).chomp
    }.join("\n")
  end

  def element_basetype(ele)
    if klass = basetype_class(ele.type)
      klass
    elsif ele.local_simpletype
      basetype_class(ele.local_simpletype.base)
    else
      nil
    end
  end

  def attribute_basetype(attr)
    if klass = basetype_class(attr.type)
      klass
    elsif attr.local_simpletype
      basetype_class(attr.local_simpletype.base)
    else
      nil
    end
  end

  def basetype_class(type)
    return nil if type.nil?
    if simpletype = @simpletypes[type]
      basetype_mapped_class(simpletype.base)
    else
      basetype_mapped_class(type)
    end
  end

  def name_element(element)
    return element.name if element.name 
    return element.ref if element.ref
    raise RuntimeError.new("cannot define name of #{element}")
  end

  def name_attribute(attribute)
    return attribute.name if attribute.name 
    return attribute.ref if attribute.ref
    raise RuntimeError.new("cannot define name of #{attribute}")
  end

  # TODO: run MethodDefCreator just once in 1.6.X.
  # MethodDefCreator should return parsed struct, not a String.
  def collect_assigned_method(wsdl, porttypename, modulepath = nil)
    name_creator = WSDL::SOAP::ClassNameCreator.new
    methoddefcreator =
      WSDL::SOAP::MethodDefCreator.new(wsdl, name_creator, modulepath, {})
    methoddefcreator.dump(porttypename)
    methoddefcreator.assigned_method
  end
end


end
end
