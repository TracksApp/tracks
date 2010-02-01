# SOAP4R - literal mapping registry.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'
require 'xsd/namedelements'


module SOAP
module Mapping


class LiteralRegistry
  include RegistrySupport

  attr_accessor :excn_handler_obj2soap
  attr_accessor :excn_handler_soap2obj

  def initialize
    super()
    @excn_handler_obj2soap = nil
    @excn_handler_soap2obj = nil
  end

  def obj2soap(obj, qname, obj_class = nil)
    soap_obj = nil
    if obj.is_a?(SOAPElement)
      soap_obj = obj
    else
      soap_obj = any2soap(obj, qname, obj_class)
    end
    return soap_obj if soap_obj
    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping.obj2soap(yield_obj, nil, nil, MAPPING_OPT)
      }
      return soap_obj if soap_obj
    end
    raise MappingError.new("cannot map #{obj.class.name} as #{qname}")
  end

  # node should be a SOAPElement
  def soap2obj(node, obj_class = nil)
    cause = nil
    begin
      return any2obj(node, obj_class)
    rescue MappingError
      cause = $!
    end
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping.soap2obj(yield_node, nil, nil, MAPPING_OPT)
	  }
      rescue Exception
      end
    end
    raise MappingError.new("cannot map #{node.elename.name}/#{node.type.name} to Ruby object", cause)
  end

private

  MAPPING_OPT = { :no_reference => true }

  def definedobj2soap(obj, definition)
    obj2soap(obj, definition.elename, definition.mapped_class)
  end

  def any2soap(obj, qname, obj_class)
    ele = nil
    if obj.is_a?(SOAP::Mapping::Object)
      return mappingobj2soap(obj, qname)
    end
    class_definition = schema_definition_from_class(obj.class)
    if class_definition.nil? and obj_class
      class_definition = schema_definition_from_class(obj_class)
    end
    elename_definition = schema_definition_from_elename(qname)
    if !class_definition and !elename_definition
      # no definition found
      return anyobj2soap(obj, qname)
    end
    if !class_definition or !elename_definition
      # use found one
      return stubobj2soap(obj, qname, class_definition || elename_definition)
    end
    # found both:
    if class_definition.class_for == elename_definition.class_for
      # if two definitions are for the same class, give qname a priority.
      return stubobj2soap(obj, qname, elename_definition)
    end
    # it should be a derived class
    return stubobj2soap(obj, qname, class_definition)
  end

  def anyobj2soap(obj, qname)
    ele = nil
    case obj
    when Hash
      ele = SOAPElement.from_obj(obj, nil)
      ele.elename = qname
    when Array
      # treat as a list of simpletype
      ele = SOAPElement.new(qname, obj.join(" "))
    when XSD::QName
      ele = SOAPElement.new(qname)
      ele.text = obj
    else
      # expected to be a basetype or an anyType.
      # SOAPStruct, etc. is used instead of SOAPElement.
      begin
        ele = Mapping.obj2soap(obj, nil, nil, MAPPING_OPT)
        ele.elename = qname
      rescue MappingError
        ele = SOAPElement.new(qname, obj.to_s)
      end
    end
    add_attributes2soap(obj, ele)
    ele
  end

  def stubobj2soap(obj, qname, definition)
    if obj.nil?
      ele = SOAPNil.new
      ele.elename = qname
    elsif obj.is_a?(::String)
      ele = SOAPElement.new(qname, obj)
    else
      ele = SOAPElement.new(qname)
    end
    ele.qualified = definition.qualified
    if definition.type and (definition.basetype or Mapping.root_type_hint)
      Mapping.reset_root_type_hint
      ele.extraattr[XSD::AttrTypeName] = definition.type
    end
    if qname.nil? and definition.elename
      ele.elename = definition.elename
    end
    return ele if obj.nil?
    stubobj2soap_elements(obj, ele, definition.elements)
    add_definedattributes2soap(obj, ele, definition)
    ele
  end

  def stubobj2soap_elements(obj, ele, definition, is_choice = false)
    added = false
    case definition
    when SchemaSequenceDefinition, SchemaEmptyDefinition
      definition.each do |eledef|
        ele_added = stubobj2soap_elements(obj, ele, eledef, is_choice)
        added = true if ele_added
      end
    when SchemaChoiceDefinition
      definition.each do |eledef|
        added = stubobj2soap_elements(obj, ele, eledef, true)
        break if added
      end
    else
      added = true
      if definition.as_any?
        any = Mapping.get_attributes_for_any(obj)
        SOAPElement.from_objs(any).each do |child|
          ele.add(child)
        end
      elsif obj.respond_to?(:each) and definition.as_array?
        obj.each do |item|
          ele.add(definedobj2soap(item, definition))
        end
      else
        child = Mapping.get_attribute(obj, definition.varname)
        if child.nil? and (is_choice or definition.minoccurs == 0)
          added = false
        else
          if child.respond_to?(:each) and definition.as_array?
            if child.empty?
              added = false
            else
              child.each do |item|
                ele.add(definedobj2soap(item, definition))
              end
            end
          else
            ele.add(definedobj2soap(child, definition))
          end
        end
      end
    end
    added
  end

  def mappingobj2soap(obj, qname)
    ele = SOAPElement.new(qname)
    obj.__xmlele.each do |key, value|
      if value.is_a?(::Array)
        value.each do |item|
          ele.add(obj2soap(item, key))
        end
      else
        ele.add(obj2soap(value, key))
      end
    end
    obj.__xmlattr.each do |key, value|
      ele.extraattr[key] = value
    end
    ele
  end

  def any2obj(node, obj_class = nil)
    is_compound = node.is_a?(::SOAP::SOAPCompoundtype)
    # trust xsi:type first
    if is_compound and node.type
      definition = schema_definition_from_type(node.type)
    end
    # element name next
    definition ||= schema_definition_from_elename(node.elename)
    # class defined in parent type last
    if obj_class
      definition ||= schema_definition_from_class(obj_class)
    end
    if definition
      obj_class = definition.class_for
    end
    if is_compound
      if definition
        return elesoap2stubobj(node, obj_class, definition)
      elsif node.is_a?(::SOAP::SOAPNameAccessible)
        return elesoap2plainobj(node)
      end
    end
    obj = Mapping.soap2obj(node, nil, obj_class, MAPPING_OPT)
    add_attributes2obj(node, obj)
    obj
  end

  def elesoap2stubobj(node, obj_class, definition)
    obj = nil
    if obj_class == ::String
      obj = node.text
    elsif obj_class < ::String
      obj = obj_class.new(node.text)
    else
      obj = Mapping.create_empty_object(obj_class)
      add_elesoap2stubobj(node, obj, definition)
    end
    add_attributes2stubobj(node, obj, definition)
    obj
  end

  def elesoap2plainobj(node)
    obj = nil
    if !node.have_member
      obj = base2obj(node, ::SOAP::SOAPString)
    else
      obj = anytype2obj(node)
      add_elesoap2plainobj(node, obj)
    end
    add_attributes2obj(node, obj)
    obj
  end

  def anytype2obj(node)
    if node.is_a?(::SOAP::SOAPBasetype)
      return node.data
    end
    ::SOAP::Mapping::Object.new
  end

  def add_elesoap2stubobj(node, obj, definition)
    vars = {}
    node.each do |name, value|
      item = definition.elements.find_element(value.elename)
      if item
        child = elesoapchild2obj(value, item)
      else
        # unknown element is treated as anyType.
        child = any2obj(value)
      end
      if item and item.as_array?
        (vars[name] ||= []) << child
      elsif vars.key?(name)
        vars[name] = [vars[name], child].flatten
      else
        vars[name] = child
      end
    end
    if obj.is_a?(::Array) and is_stubobj_elements_for_array(vars)
      Array.instance_method(:replace).bind(obj).call(vars.values[0])
    else
      Mapping.set_attributes(obj, vars)
    end
  end

  def elesoapchild2obj(value, eledef)
    if eledef.mapped_class
      if eledef.mapped_class.include?(::SOAP::SOAPBasetype)
        base2obj(value, eledef.mapped_class)
      else
        any2obj(value, eledef.mapped_class)
      end
    else
      child_definition = schema_definition_from_elename(eledef.elename)
      if child_definition
        any2obj(value, child_definition.class_for)
      else
        # untyped element is treated as anyType.
        any2obj(value)
      end
    end
  end

  def add_attributes2stubobj(node, obj, definition)
    return if obj.nil? or node.extraattr.empty?
    if attributes = definition.attributes
      define_xmlattr(obj)
      attributes.each do |qname, class_name|
        child = node.extraattr[qname]
        next if child.nil?
        if class_name
          klass = Mapping.class_from_name(class_name)
          if klass.include?(::SOAP::SOAPBasetype)
            child = klass.to_data(child)
          end
        end
        obj.__xmlattr[qname] = child
        define_xmlattr_accessor(obj, qname)
      end
    end
  end

  def add_elesoap2plainobj(node, obj)
    node.each do |name, value|
      obj.__add_xmlele_value(value.elename, any2obj(value))
    end
  end

  def add_attributes2obj(node, obj)
    return if obj.nil? or node.extraattr.empty?
    define_xmlattr(obj)
    node.extraattr.each do |qname, value|
      obj.__xmlattr[qname] = value
      define_xmlattr_accessor(obj, qname)
    end
  end

  # Mapping.define_attr_accessor calls define_method with proc and it exhausts
  # much memory for each singleton Object.  just instance_eval instead of it.
  def define_xmlattr_accessor(obj, qname)
    # untaint depends GenSupport.safemethodname
    name = Mapping.safemethodname('xmlattr_' + qname.name).untaint
    unless obj.respond_to?(name)
      # untaint depends QName#dump
      qnamedump = qname.dump.untaint
      obj.instance_eval <<-EOS
        def #{name}
          @__xmlattr[#{qnamedump}]
        end

        def #{name}=(value)
          @__xmlattr[#{qnamedump}] = value
        end
      EOS
    end
  end

  # Mapping.define_attr_accessor calls define_method with proc and it exhausts
  # much memory for each singleton Object.  just instance_eval instead of it.
  def define_xmlattr(obj)
    obj.instance_variable_set('@__xmlattr', {})
    unless obj.respond_to?(:__xmlattr)
      obj.instance_eval <<-EOS
        def __xmlattr
          @__xmlattr
        end
      EOS
    end
  end
end


end
end
