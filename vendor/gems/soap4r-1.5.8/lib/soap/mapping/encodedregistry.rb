# SOAP4R - encoded mapping registry.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'
require 'soap/mapping/factory'
require 'soap/mapping/rubytypeFactory'


module SOAP
module Mapping


# Inner class to pass an exception.
class SOAPException
  attr_reader :excn_type_name, :cause

  def initialize(e)
    @excn_type_name = Mapping.name2elename(e.class.to_s)
    @cause = e
  end

  def to_e
    if @cause.is_a?(::Exception)
      @cause.extend(::SOAP::Mapping::MappedException)
      return @cause
    elsif @cause.respond_to?(:message) and @cause.respond_to?(:backtrace)
      e = RuntimeError.new(@cause.message)
      e.set_backtrace(@cause.backtrace)
      return e
    end
    klass = Mapping.class_from_name(Mapping.elename2name(@excn_type_name.to_s))
    if klass.nil? or not klass <= ::Exception
      return RuntimeError.new(@cause.inspect)
    end
    obj = klass.new(@cause.message)
    obj.extend(::SOAP::Mapping::MappedException)
    obj
  end
end


class EncodedRegistry
  include TraverseSupport
  include RegistrySupport

  class Map
    def initialize(registry)
      @obj2soap = {}
      @soap2obj = {}
      @registry = registry
    end

    def obj2soap(obj)
      klass = obj.class
      if map = @obj2soap[klass]
        map.each do |soap_class, factory, info|
          ret = factory.obj2soap(soap_class, obj, info, @registry)
          return ret if ret
        end
      end
      klass.ancestors.each do |baseclass|
        next if baseclass == klass
        if map = @obj2soap[baseclass]
          map.each do |soap_class, factory, info|
            if info[:derived_class]
              ret = factory.obj2soap(soap_class, obj, info, @registry)
              return ret if ret
            end
          end
        end
      end
      nil
    end

    def soap2obj(node, klass = nil)
      if map = @soap2obj[node.class]
        map.each do |obj_class, factory, info|
          next if klass and obj_class != klass
          conv, obj = factory.soap2obj(obj_class, node, info, @registry)
          return true, obj if conv
        end
      end
      return false, nil
    end

    # Give priority to former entry.
    def init(init_map = [])
      clear
      init_map.reverse_each do |obj_class, soap_class, factory, info|
        add(obj_class, soap_class, factory, info)
      end
    end

    # Give priority to latter entry.
    def add(obj_class, soap_class, factory, info)
      info ||= {}
      (@obj2soap[obj_class] ||= []).unshift([soap_class, factory, info])
      (@soap2obj[soap_class] ||= []).unshift([obj_class, factory, info])
    end

    def clear
      @obj2soap.clear
      @soap2obj.clear
    end

    def find_mapped_soap_class(target_obj_class)
      map = @obj2soap[target_obj_class]
      map.empty? ? nil : map[0][1]
    end

    def find_mapped_obj_class(target_soap_class)
      map = @soap2obj[target_soap_class]
      map.empty? ? nil : map[0][0]
    end
  end

  StringFactory = StringFactory_.new
  BasetypeFactory = BasetypeFactory_.new
  FixnumFactory = FixnumFactory_.new
  DateTimeFactory = DateTimeFactory_.new
  ArrayFactory = ArrayFactory_.new
  Base64Factory = Base64Factory_.new
  URIFactory = URIFactory_.new
  TypedArrayFactory = TypedArrayFactory_.new
  TypedStructFactory = TypedStructFactory_.new

  HashFactory = HashFactory_.new

  SOAPBaseMap = [
    [::NilClass,     ::SOAP::SOAPNil,        BasetypeFactory],
    [::TrueClass,    ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::FalseClass,   ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::String,       ::SOAP::SOAPString,     StringFactory,
      {:derived_class => true}],
    [::DateTime,     ::SOAP::SOAPDateTime,   DateTimeFactory],
    [::Date,         ::SOAP::SOAPDate,       DateTimeFactory],
    [::Time,         ::SOAP::SOAPDateTime,   DateTimeFactory],
    [::Time,         ::SOAP::SOAPTime,       DateTimeFactory],
    [::Float,        ::SOAP::SOAPDouble,     BasetypeFactory,
      {:derived_class => true}],
    [::Float,        ::SOAP::SOAPFloat,      BasetypeFactory,
      {:derived_class => true}],
    [::Fixnum,       ::SOAP::SOAPInt,        FixnumFactory],
    [::Integer,      ::SOAP::SOAPInt,        BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPLong,       BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPInteger,    BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPShort,      BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPByte,       BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNonPositiveInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNegativeInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNonNegativeInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPPositiveInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedLong, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedInt, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedShort, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedByte, BasetypeFactory,
      {:derived_class => true}],
    [::URI::Generic, ::SOAP::SOAPAnyURI,     URIFactory,
      {:derived_class => true}],
    [::String,       ::SOAP::SOAPBase64,     Base64Factory],
    [::String,       ::SOAP::SOAPHexBinary,  Base64Factory],
    [::String,       ::SOAP::SOAPDecimal,    BasetypeFactory],
    [::String,       ::SOAP::SOAPDuration,   BasetypeFactory],
    [::String,       ::SOAP::SOAPGYearMonth, BasetypeFactory],
    [::String,       ::SOAP::SOAPGYear,      BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonthDay,  BasetypeFactory],
    [::String,       ::SOAP::SOAPGDay,       BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonth,     BasetypeFactory],
    [::String,       ::SOAP::SOAPQName,      BasetypeFactory],

    [::Hash,         ::SOAP::SOAPArray,      HashFactory,
      {:derived_class => true}],
    [::Hash,         ::SOAP::SOAPStruct,     HashFactory,
      {:derived_class => true}],

    [::Array,        ::SOAP::SOAPArray,      ArrayFactory,
      {:derived_class => true}],

    [::SOAP::Mapping::SOAPException,
		     ::SOAP::SOAPStruct,     TypedStructFactory,
      {:type => XSD::QName.new(RubyCustomTypeNamespace, "SOAPException")}],
 ]

  RubyOriginalMap = [
    [::NilClass,     ::SOAP::SOAPNil,        BasetypeFactory],
    [::TrueClass,    ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::FalseClass,   ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::String,       ::SOAP::SOAPString,     StringFactory],
    [::DateTime,     ::SOAP::SOAPDateTime,   DateTimeFactory],
    [::Date,         ::SOAP::SOAPDate,       DateTimeFactory],
    [::Time,         ::SOAP::SOAPDateTime,   DateTimeFactory],
    [::Time,         ::SOAP::SOAPTime,       DateTimeFactory],
    [::Float,        ::SOAP::SOAPDouble,     BasetypeFactory,
      {:derived_class => true}],
    [::Float,        ::SOAP::SOAPFloat,      BasetypeFactory,
      {:derived_class => true}],
    [::Fixnum,       ::SOAP::SOAPInt,        FixnumFactory],
    [::Integer,      ::SOAP::SOAPInt,        BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPLong,       BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPInteger,    BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPShort,      BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPByte,       BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNonPositiveInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNegativeInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPNonNegativeInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPPositiveInteger, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedLong, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedInt, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedShort, BasetypeFactory,
      {:derived_class => true}],
    [::Integer,      ::SOAP::SOAPUnsignedByte, BasetypeFactory,
      {:derived_class => true}],
    [::URI::Generic, ::SOAP::SOAPAnyURI,     URIFactory,
      {:derived_class => true}],
    [::String,       ::SOAP::SOAPBase64,     Base64Factory],
    [::String,       ::SOAP::SOAPHexBinary,  Base64Factory],
    [::String,       ::SOAP::SOAPDecimal,    BasetypeFactory],
    [::String,       ::SOAP::SOAPDuration,   BasetypeFactory],
    [::String,       ::SOAP::SOAPGYearMonth, BasetypeFactory],
    [::String,       ::SOAP::SOAPGYear,      BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonthDay,  BasetypeFactory],
    [::String,       ::SOAP::SOAPGDay,       BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonth,     BasetypeFactory],
    [::String,       ::SOAP::SOAPQName,      BasetypeFactory],

    [::Hash,         ::SOAP::SOAPArray,      HashFactory],
    [::Hash,         ::SOAP::SOAPStruct,     HashFactory],

    # Does not allow Array's subclass here.
    [::Array,        ::SOAP::SOAPArray,      ArrayFactory],

    [::SOAP::Mapping::SOAPException,
                     ::SOAP::SOAPStruct,     TypedStructFactory,
      {:type => XSD::QName.new(RubyCustomTypeNamespace, "SOAPException")}],
  ]

  attr_accessor :default_factory
  attr_accessor :excn_handler_obj2soap
  attr_accessor :excn_handler_soap2obj

  def initialize(config = {})
    super()
    @config = config
    @map = Map.new(self)
    if @config[:allow_original_mapping]
      @allow_original_mapping = true
      @map.init(RubyOriginalMap)
    else
      @allow_original_mapping = false
      @map.init(SOAPBaseMap)
    end
    @allow_untyped_struct = @config.key?(:allow_untyped_struct) ?
      @config[:allow_untyped_struct] : true
    @rubytype_factory = RubytypeFactory.new(
      :allow_untyped_struct => @allow_untyped_struct,
      :allow_original_mapping => @allow_original_mapping
    )
    @default_factory = @rubytype_factory
    @excn_handler_obj2soap = nil
    @excn_handler_soap2obj = nil
  end

  # initial mapping interface
  # new interface Registry#register is defined in RegisterSupport
  def add(obj_class, soap_class, factory, info = nil)
    @map.add(obj_class, soap_class, factory, info)
  end
  alias set add

  def obj2soap(obj, type_qname = nil)
    soap = _obj2soap(obj, type_qname)
    if @allow_original_mapping
      addextend2soap(soap, obj)
    end
    soap
  end

  def soap2obj(node, klass = nil)
    obj = _soap2obj(node, klass)
    if @allow_original_mapping
      addextend2obj(obj, node.extraattr[RubyExtendName])
      addiv2obj(obj, node.extraattr[RubyIVarName])
    end
    obj
  end

  def find_mapped_soap_class(obj_class)
    @map.find_mapped_soap_class(obj_class)
  end

  def find_mapped_obj_class(soap_class)
    @map.find_mapped_obj_class(soap_class)
  end

private

  def _obj2soap(obj, type_qname = nil)
    ret = nil
    if obj.is_a?(SOAPCompoundtype)
      obj.replace do |ele|
        Mapping._obj2soap(ele, self)
      end
      return obj
    elsif obj.is_a?(SOAPBasetype)
      return obj
    elsif type_qname && type = TypeMap[type_qname]
      return base2soap(obj, type)
    end
    cause = nil
    begin 
      if definition = schema_definition_from_class(obj.class)
        return stubobj2soap(obj, definition)
      end
      ret = @map.obj2soap(obj) ||
        @default_factory.obj2soap(nil, obj, nil, self)
      return ret if ret
    rescue MappingError
      cause = $!
    end
    if @excn_handler_obj2soap
      ret = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
      return ret if ret
    end
    raise MappingError.new("Cannot map #{ obj.class.name } to SOAP/OM.", cause)
  end

  # Might return nil as a mapping result.
  def _soap2obj(node, klass = nil)
    definition = find_node_definition(node)
    if klass
      klass_definition = schema_definition_from_class(klass)
      if definition and (definition.class_for < klass)
        klass = definition.class_for
      else
        definition = klass_definition
      end
    else
      klass = definition.class_for if definition
    end
    if definition and node.is_a?(::SOAP::SOAPNameAccessible)
      return elesoap2stubobj(node, klass, definition)
    end
    if node.extraattr.key?(RubyTypeName)
      conv, obj = @rubytype_factory.soap2obj(nil, node, nil, self)
      return obj if conv
    end
    conv, obj = @map.soap2obj(node)
    return obj if conv
    conv, obj = @default_factory.soap2obj(nil, node, nil, self)
    return obj if conv
    cause = nil
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping._soap2obj(yield_node, self)
	  }
      rescue Exception
        cause = $!
      end
    end
    raise MappingError.new("Cannot map #{ node.type } to Ruby object.", cause)
  end

  def addiv2obj(obj, attr)
    return unless attr
    vars = {}
    attr.__getobj__.each do |name, value|
      vars[name] = Mapping._soap2obj(value, self)
    end
    Mapping.set_attributes(obj, vars)
  end

  def addextend2obj(obj, attr)
    return unless attr
    attr.split(/ /).reverse_each do |mstr|
      obj.extend(Mapping.module_from_name(mstr))
    end
  end

  def addextend2soap(node, obj)
    return if obj.is_a?(Symbol) or obj.is_a?(Fixnum)
    list = (class << obj; self; end).ancestors - obj.class.ancestors
    unless list.empty?
      node.extraattr[RubyExtendName] = list.collect { |c|
        name = c.name
	if name.nil? or name.empty?
  	  raise TypeError.new("singleton can't be dumped #{ obj }")
   	end
	name
      }.join(" ")
    end
  end

  def stubobj2soap(obj, definition)
    case obj
    when ::Array
      array2soap(obj, definition)
    else
      unknownstubobj2soap(obj, definition)
    end
  end

  def array2soap(obj, definition)
    return SOAPNil.new if obj.nil?      # ToDo: check nillable.
    eledef = definition.elements[0]
    soap_obj = SOAPArray.new(ValueArrayName, 1, eledef.elename)
    mark_marshalled_obj(obj, soap_obj)
    obj.each do |item|
      soap_obj.add(typedobj2soap(item, eledef.mapped_class))
    end
    soap_obj
  end

  def unknownstubobj2soap(obj, definition)
    return SOAPNil.new if obj.nil?
    if definition.elements.size == 0
      ele = Mapping.obj2soap(obj)
      ele.elename = definition.elename if definition.elename
      ele.extraattr[XSD::AttrTypeName] = definition.type if definition.type
      return ele
    else
      ele = SOAPStruct.new(definition.type)
      mark_marshalled_obj(obj, ele)
    end
    definition.elements.each do |eledef|
      name = eledef.elename.name
      if obj.respond_to?(:each) and eledef.as_array?
        obj.each do |item|
          ele.add(name, typedobj2soap(item, eledef.mapped_class))
        end
      else
        child = Mapping.get_attribute(obj, eledef.varname)
        if child.respond_to?(:each) and eledef.as_array?
          child.each do |item|
            ele.add(name, typedobj2soap(item, eledef.mapped_class))
          end
        else
          ele.add(name, typedobj2soap(child, eledef.mapped_class))
        end
      end
    end
    ele
  end

  def typedobj2soap(value, klass)
    if klass and klass.include?(::SOAP::SOAPBasetype)
      base2soap(value, klass)
    else
      Mapping._obj2soap(value, self)
    end
  end

  def elesoap2stubobj(node, obj_class, definition)
    obj = Mapping.create_empty_object(obj_class)
    add_elesoap2stubobj(node, obj, definition)
    obj
  end

  # XXX consider to merge with the method in LiteralRegistry
  def add_elesoap2stubobj(node, obj, definition)
    vars = {}
    node.each do |name, value|
      item = definition.elements.find_element(value.elename)
      if item
        child = soap2typedobj(value, item.mapped_class)
      else
        # unknown element is treated as anyType.
        child = Mapping._soap2obj(value, self)
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

  def soap2typedobj(value, klass)
    unless klass
      raise MappingError.new("unknown class: #{klass}")
    end
    if klass.include?(::SOAP::SOAPBasetype)
      obj = base2obj(value, klass)
    else
      obj = Mapping._soap2obj(value, self, klass)
    end
    obj
  end
end


Registry = EncodedRegistry
DefaultRegistry = EncodedRegistry.new
RubyOriginalRegistry = EncodedRegistry.new(:allow_original_mapping => true)


end
end
