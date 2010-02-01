# WSDL4R - XMLSchema attributeGroup definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module XMLSchema


class AttributeGroup < Info
  class << self
    if RUBY_VERSION > "1.7.0"
      def attr_reader_ref(symbol)
        name = symbol.to_s
        define_method(name) {
          instance_variable_get("@#{name}") ||
            (refelement ? refelement.__send__(name) : nil)
        }
      end
    else
      def attr_reader_ref(symbol)
        name = symbol.to_s
        module_eval <<-EOS
          def #{name}
            @#{name} || (refelement ? refelement.#{name} : nil)
          end
        EOS
      end
    end
  end

  attr_writer :name	# required
  attr_writer :attributes

  attr_reader_ref :name
  attr_reader_ref :attributes

  attr_accessor :ref

  def initialize
    super
    @name = nil
    @attributes = nil
    @ref = nil
    @refelement = nil
  end

  def refelement
    @refelement ||= root.collect_attributegroups[@ref]
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    case element
    when AttributeName
      @attributes ||= XSD::NamedElements.new
      o = Attribute.new
      @attributes << o
      o
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value.source)
    when RefAttrName
      @ref = value
    else
      nil
    end
  end
end


end
end
