# SOAP4R - Mapping registry.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'


module SOAP


module Marshallable
  # @@type_ns = Mapping::RubyCustomTypeNamespace
end


module Mapping

  
module MappedException; end


RubyTypeName = XSD::QName.new(RubyTypeInstanceNamespace, 'rubyType')
RubyExtendName = XSD::QName.new(RubyTypeInstanceNamespace, 'extends')
RubyIVarName = XSD::QName.new(RubyTypeInstanceNamespace, 'ivars')


# For anyType object: SOAP::Mapping::Object not ::Object
class Object
  def initialize
    @__xmlele_type = {}
    @__xmlele = []
    @__xmlattr = {}
  end

  def inspect
    sprintf("#<%s:0x%x%s>", self.class.name, __id__,
      @__xmlele.collect { |name, value| " #{name}=#{value.inspect}" }.join)
  end

  def __xmlattr
    @__xmlattr
  end

  def __xmlele
    @__xmlele
  end

  def [](qname)
    qname = Mapping.to_qname(qname)
    @__xmlele.each do |k, v|
      return v if k == qname
    end
    # fallback
    @__xmlele.each do |k, v|
      return v if k.name == qname.name
    end
    nil
  end

  def []=(qname, value)
    qname = Mapping.to_qname(qname)
    found = false
    @__xmlele.each do |pair|
      if pair[0] == qname
        found = true
        pair[1] = value
      end
    end
    unless found
      __define_attr_accessor(qname)
      @__xmlele << [qname, value]
    end
    @__xmlele_type[qname] = :single
  end

  def __add_xmlele_value(qname, value)
    found = false
    @__xmlele.map! do |k, v|
      if k == qname
        found = true
        [k, __set_xmlele_value(k, v, value)]
      else
        [k, v]
      end
    end
    unless found
      __define_attr_accessor(qname)
      @__xmlele << [qname, value]
      @__xmlele_type[qname] = :single
    end
    value
  end

  def marshal_load(dumpobj)
    __import(dumpobj)
  end

private

  # Mapping.define_attr_accessor calls define_method with proc and it exhausts
  # much memory for each singleton Object.  just instance_eval instead of it.
  def __define_attr_accessor(qname)
    # untaint depends GenSupport.safemethodname
    name = Mapping.safemethodname(qname.name).untaint
    # untaint depends on QName#dump
    qnamedump = qname.dump.untaint
    singleton = false
    unless self.respond_to?(name)
      singleton = true
      instance_eval <<-EOS
        def #{name}
          self[#{qnamedump}]
        end
      EOS
    end
    unless self.respond_to?(name + "=")
      singleton = true
      instance_eval <<-EOS
        def #{name}=(value)
          self[#{qnamedump}] = value
        end
      EOS
    end
    if singleton && !self.respond_to?(:marshal_dump)
      instance_eval <<-EOS
        def marshal_dump
          __export
        end
      EOS
    end
  end

  def __set_xmlele_value(key, org, value)
    case @__xmlele_type[key]
    when :multi
      org << value
      org
    when :single
      @__xmlele_type[key] = :multi
      [org, value]
    else
      raise RuntimeError.new("unknown type")
    end
  end

  def __export
    dumpobj = ::SOAP::Mapping::Object.new
    dumpobj.__xmlele.replace(@__xmlele)
    dumpobj.__xmlattr.replace(@__xmlattr)
    dumpobj
  end

  def __import(dumpobj)
    @__xmlele_type = {}
    @__xmlele = []
    @__xmlattr = {}
    dumpobj.__xmlele.each do |qname, value|
      __add_xmlele_value(qname, value)
    end
    @__xmlattr.replace(dumpobj.__xmlattr)
  end
end


class MappingError < Error; end


module RegistrySupport
  def initialize
    super()
    @class_schema_definition = {}
    @class_elename_schema_definition = {}
    @elename_schema_definition = {}
    @type_schema_definition = {}
  end

  def register(definition)
    obj_class = definition[:class]
    definition = Mapping.create_schema_definition(obj_class, definition)
    # give complexType definition a priority explicitly
    if !@class_schema_definition[obj_class] or definition.type
      @class_schema_definition[obj_class] = definition
    end
    if definition.elename and !definition.is_anonymous?
      @class_elename_schema_definition[obj_class] = definition
      @elename_schema_definition[definition.elename] = definition
    end
    if definition.type
      @type_schema_definition[definition.type] = definition
    end
  end

  def schema_definition_from_class(klass)
    @class_schema_definition[klass] || Mapping.schema_definition_classdef(klass)
  end

  def elename_schema_definition_from_class(klass)
    @class_elename_schema_definition[klass]
  end

  def schema_definition_from_elename(qname)
    @elename_schema_definition[qname]
  end

  def schema_definition_from_type(type)
    @type_schema_definition[type]
  end

  def find_node_definition(node)
    schema_definition_from_type(node.type) ||
      schema_definition_from_elename(node.elename) ||
      find_schema_definition(node.elename.name) ||
      find_schema_definition(node.type.name)
  end

  def find_schema_definition(name)
    return nil unless name
    typestr = Mapping.safeconstname(name)
    obj_class = Mapping.class_from_name(typestr)
    if obj_class
      schema_definition_from_class(obj_class)
    end
  end
  
  def add_attributes2soap(obj, ele)
    if definition = Mapping.schema_definition_classdef(obj.class)
      add_definedattributes2soap(obj, ele, definition)
    elsif obj.respond_to?(:__xmlattr)
      obj.__xmlattr.each do |key, value|
        ele.extraattr[key] = value
      end
    end
  end

  def add_definedattributes2soap(obj, ele, typedef)
    if typedef.attributes
      typedef.attributes.each do |qname, param|
        value = get_xmlattr_value(obj, qname)
        ele.extraattr[qname] = value unless value.nil?
      end
    end
  end

  def get_xmlattr_value(obj, qname)
    attrname = 'xmlattr_' + qname.name
    value = Mapping.get_attribute(obj, attrname)
    if value.nil?
      attrname = Mapping.safemethodname('xmlattr_' + qname.name)
      value = Mapping.get_attribute(obj, attrname)
    end
    value
  end

  def base2soap(obj, type, qualified = nil)
    return SOAPNil.new if obj.nil?
    soap_obj = nil
    if type <= XSD::XSDString
      str = XSD::Charset.encoding_conv(obj.to_s, Mapping.external_ces,
        XSD::Charset.encoding)
      soap_obj = type.new(str)
    else
      soap_obj = type.new(obj)
    end
    soap_obj.qualified = qualified
    soap_obj
  end

  def base2obj(value, klass)
    v = if value.respond_to?(:data)
          value.data
        elsif value.respond_to?(:text)
          value.text
        else
          nil
        end
    if value.is_a?(klass)
      v
    else
      klass.to_data(v)
    end
  end

  def is_stubobj_elements_for_array(vars)
    vars.keys.size == 1 and vars.values[0].is_a?(::Array)
  end
end


end
end
