# WSDL4R - Creating MappingRegistry support.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/soap/classDefCreatorSupport'


module WSDL
module SOAP


# requires @defined_const = {}, @dump_with_inner, @modulepath
module MappingRegistryCreatorSupport
  include ClassDefCreatorSupport
  include XSD::CodeGen

  def dump_with_inner
    @dump_with_inner = []
    @dump_with_inner.unshift(yield)
    @dump_with_inner.join("\n")
  end

  def dump_complextypedef(mpath, qname, typedef, as_element = nil, opt = {})
    case typedef.compoundtype
    when :TYPE_STRUCT, :TYPE_EMPTY
      dump_complex_typemap(mpath, qname, typedef, as_element, opt)
    when :TYPE_ARRAY
      dump_array_typemap(mpath, qname, typedef, as_element, opt)
    when :TYPE_SIMPLE
      dump_simple_typemap(mpath, qname, typedef, as_element, opt)
    when :TYPE_MAP
      # mapped as a general Hash
      nil
    else
      raise RuntimeError.new(
        "unknown kind of complexContent: #{typedef.compoundtype}")
    end
  end

  def dump_array_typemap(mpath, qname, typedef, as_element, opt)
    if typedef.find_soapenc_arytype
      if opt[:encoded]
        dump_encoded_array_typemap(mpath, qname, typedef, as_element, opt)
      end
    else
      dump_literal_array_typemap(mpath, qname, typedef, as_element, opt)
    end
  end

  def dump_complex_typemap(mpath, qname, typedef, as_element, opt)
    var = {}
    define_dump_class(var, mpath, qname, typedef, as_element, opt)
    schema_ns = (var[:schema_name] || var[:schema_type]).namespace
    if var[:schema_type] and typedef.base
      var[:schema_basetype] = typedef.base
    end
    parentmodule = var[:class]
    parsed_element =
      parse_elements(typedef.elements, qname.namespace, parentmodule, opt)
    if typedef.choice?
      parsed_element.unshift(:choice)
    end
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    unless typedef.attributes.empty?
      var[:schema_attribute] = define_attribute(typedef.attributes)
    end
    assign_const(schema_ns, 'Ns')
    dump_entry(@varname, var)
  end

  def dump_simple_typemap(mpath, qname, typedef, as_element, opt)
    var = {}
    define_dump_class(var, mpath, qname, typedef, as_element, opt)
    schema_ns = (var[:schema_name] || var[:schema_type]).namespace
    unless typedef.attributes.empty?
      var[:schema_attribute] = define_attribute(typedef.attributes)
    end
    assign_const(schema_ns, 'Ns')
    dump_entry(@varname, var)
  end

  def dump_schema_element_definition(definition, indent = 0)
    return '[]' if definition.empty?
    sp = ' ' * indent
    if definition[0] == :choice
      definition.shift
      "[ :choice,\n" +
        dump_schema_element(definition, indent + 2) + "\n" + sp + "]"
    elsif definition[0].is_a?(::Array)
      "[\n" +
        dump_schema_element(definition, indent + 2) + "\n" + sp + "]"
    else
      varname, name, type, occurrence = definition
      '[' + [
        varname.dump,
        dump_type(name, type),
        dump_occurrence(occurrence)
      ].compact.join(', ') + ']'
    end
  end

  def dump_schema_element(schema_element, indent = 0)
    sp = ' ' * indent
    delimiter = ",\n" + sp
    sp + schema_element.collect { |definition|
      dump_schema_element_definition(definition, indent)
    }.join(delimiter)
  end

  def dump_type(name, type)
    if name
      assign_const(name.namespace, 'Ns')
      '[' + ndq(type) + ', ' + dqname(name) + ']'
    else
      ndq(type)
    end
  end

  def dump_occurrence(occurrence)
    if occurrence and occurrence != [1, 1] # default
      minoccurs, maxoccurs = occurrence
      maxoccurs ||= 'nil'
      "[#{minoccurs}, #{maxoccurs}]"
    end
  end

  def parse_elements(elements, base_namespace, mpath, opt)
    schema_element = []
    any = false
    elements.each do |element|
      case element
      when XMLSchema::Any
        # only 1 <any/> is allowed for now.
        raise RuntimeError.new("duplicated 'any'") if any
        any = true
        varname = 'any' # not used
        eleqname = XSD::AnyTypeName
        type = nil
        occurrence = nil
        schema_element << [varname, eleqname, type, occurrence]
      when XMLSchema::Element
        next if element.ref == SchemaName
        typebase = @modulepath
        if element.anonymous_type?
          child_opt = {
            :qualified => (element.elementform == 'qualified'),
            :is_anonymous => true
          }
          @dump_with_inner << dump_complextypedef(mpath, element.name, element.local_complextype, nil, child_opt)
          typebase = mpath
        end
        type = create_type_name(typebase, element)
        name = name_element(element).name
        varname = safevarname(name)
        if element.map_as_array?
          if type
            type += '[]'
          else
            type = '[]'
          end
        end
        # nil means @@schema_ns + varname
        eleqname = element.name || element.ref
        if eleqname && varname == name && eleqname.namespace == base_namespace
          eleqname = nil
        end
        occurrence = [element.minoccurs, element.maxoccurs]
        schema_element << [varname, eleqname, type, occurrence]
      when WSDL::XMLSchema::Sequence
        child_schema_element =
          parse_elements(element.elements, base_namespace, mpath, opt)
        schema_element << child_schema_element
      when WSDL::XMLSchema::Choice
        child_schema_element =
          parse_elements(element.elements, base_namespace, mpath, opt)
        if !element.map_as_array?
          # choice + maxOccurs="unbounded" is treated just as 'all' now.
          child_schema_element.unshift(:choice)
        end
        schema_element << child_schema_element
      when WSDL::XMLSchema::Group
        if element.content.nil?
          warn("no group definition found: #{element}")
          next
        end
        child_schema_element =
          parse_elements(element.content.elements, base_namespace, mpath, opt)
        schema_element.concat(child_schema_element)
      else
        raise RuntimeError.new("unknown type: #{element}")
      end
    end
    schema_element
  end

  def define_attribute(attributes)
    schema_attribute = []
    attributes.each do |attribute|
      name = name_attribute(attribute)
      if klass = attribute_basetype(attribute)
        type = klass.name
      else
        warn("unresolved attribute type #{attribute.type} for #{name}")
        type = nil
      end
      schema_attribute << [name, type]
    end
    "{\n    " +
      schema_attribute.collect { |name, type|
        assign_const(name.namespace, 'Ns')
        dqname(name) + ' => ' + ndq(type)
      }.join(",\n    ") +
    "\n  }"
  end

  def dump_entry(regname, var)
    "#{regname}.register(\n  " +
      [
        dump_entry_item(var, :class),
        dump_entry_item(var, :soap_class),
        dump_entry_item(var, :schema_name, :qname),
        dump_entry_item(var, :schema_type, :qname),
        dump_entry_item(var, :is_anonymous),
        dump_entry_item(var, :schema_basetype, :qname),
        dump_entry_item(var, :schema_qualified),
        dump_entry_item(var, :schema_element),
        dump_entry_item(var, :schema_attribute)
      ].compact.join(",\n  ") +
    "\n)\n"
  end

  def dump_entry_item(var, key, dump_type = :none)
    if var.key?(key)
      case dump_type
      when :none
        ":#{key} => #{var[key]}"
      when :string
        if @defined_const.key?(var[key])
          ":#{key} => #{@defined_const[var[key]]}"
        else
          ":#{key} => #{ndq(var[key])}"
        end
      when :qname
        qname = var[key]
        if @defined_const.key?(qname.namespace)
          ns = @defined_const[qname.namespace]
        else
          ns = ndq(qname.namespace)
        end
        ":#{key} => XSD::QName.new(#{ns}, #{ndq(qname.name)})"
      else
        raise "Unknown dump type: #{dump_type}"
      end
    end
  end

  def dump_simpletypedef(mpath, qname, simpletype, as_element = nil, opt = {})
    if simpletype.restriction
      dump_simpletypedef_restriction(mpath, qname, simpletype, as_element, opt)
    elsif simpletype.list
      dump_simpletypedef_list(mpath, qname, simpletype, as_element, opt)
    elsif simpletype.union
      dump_simpletypedef_union(mpath, qname, simpletype, as_element, opt)
    else
      raise RuntimeError.new("unknown kind of simpletype: #{simpletype}")
    end
  end

  def dump_simpletypedef_restriction(mpath, qname, typedef, as_element, opt)
    restriction = typedef.restriction
    unless restriction.enumeration?
      # not supported.  minlength?
      return nil
    end
    var = {}
    define_dump_class(var, mpath, qname, typedef, as_element, opt)
    schema_ns = (var[:schema_name] || var[:schema_type]).namespace
    assign_const(schema_ns, 'Ns')
    dump_entry(@varname, var)
  end

  def dump_simpletypedef_list(mpath, qname, typedef, as_element, opt)
    nil
  end

  def dump_simpletypedef_union(mpath, qname, typedef, as_element, opt)
    nil
  end

  DEFAULT_ITEM_NAME = XSD::QName.new(nil, 'item')

  def dump_literal_array_typemap(mpath, qname, typedef, as_element, opt)
    var = {}
    define_dump_class(var, mpath, qname, typedef, as_element, opt)
    schema_ns = (var[:schema_name] || var[:schema_type]).namespace
    parsed_element =
      parse_elements(typedef.elements, qname.namespace, var[:class], opt)
    if parsed_element.empty?
      parsed_element = [create_array_element_definition(typedef, mpath)]
    end
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    assign_const(schema_ns, 'Ns')
    dump_entry(@varname, var)
  end

  def dump_encoded_array_typemap(mpath, qname, typedef, as_element, opt)
    arytype = typedef.find_arytype || XSD::AnyTypeName
    type = XSD::QName.new(arytype.namespace, arytype.name.sub(/\[(?:,)*\]$/, ''))
    return <<__EOD__
#{@varname}.set(
  #{mapped_class_name(qname, mpath)},
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
  { :type => #{dqname(type)} }
)
__EOD__
  end

  # used when "soapenc:arrayType" definition
  def create_array_element_definition(typedef, mpath)
    child_type = typedef.child_type
    child_element = typedef.find_aryelement
    if child_type == XSD::AnyTypeName
      type = nil
    elsif child_element
      if klass = element_basetype(child_element)
        type = klass.name
      else
        typename = child_element.type || child_element.name
        type = mapped_class_name(typename, mpath)
      end
    elsif child_type
      type = mapped_class_name(child_type, mpath)
    else
      type = nil
    end
    occurrence = [0, nil]
    if child_element and child_element.name
      if child_element.map_as_array?
        type << '[]' if type
        occurrence = [child_element.minoccurs, child_element.maxoccurs]
      end
      child_element_name = child_element.name
    else
      child_element_name = DEFAULT_ITEM_NAME
    end
    [child_element_name.name, child_element_name, type, occurrence]
  end

  def define_dump_class(var, mpath, qname, typedef, as_element, opt)
    var[:class] = mapped_class_name(qname, mpath)
    if as_element
      var[:schema_name] = as_element
      schema_ns = as_element.namespace
    elsif typedef.name.nil?
      var[:schema_name] = qname
      schema_ns = qname.namespace
    else
      var[:schema_type] = qname
      schema_ns = qname.namespace
    end
    var[:is_anonymous] = opt[:is_anonymous] if opt.key?(:is_anonymous)
    # true, false, or nil
    if opt.key?(:qualified)
      var[:schema_qualified] = opt[:qualified].to_s
    end
  end
end


end
end
