# SOAP4R - A method definition
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP
module RPC


class MethodDef
  attr_reader :name
  attr_reader :soapaction
  attr_reader :qname
  attr_accessor :style
  attr_accessor :inputuse
  attr_accessor :outputuse
  attr_reader :parameters
  attr_reader :faults

  def initialize(name, soapaction, qname)
    @name = name
    @soapaction = soapaction
    @qname = qname
    @style = @inputuse = @outputuse = nil
    @parameters = []
    @faults = {}
  end

  def add_parameter(io_type, name, qname, mapped_class)
    @parameters << Parameter.new(io_type, name, qname, mapped_class)
  end

  def self.to_param(param)
    if param.respond_to?(:io_type)
      param
    else
      io_type, name, param_type = param
      mapped_class_str, nsdef, namedef = param_type
      if nsdef && namedef
        qname = XSD::QName.new(nsdef, namedef)
      else
        qname = nil
      end
      MethodDef::Parameter.new(io_type.to_sym, name, qname, mapped_class_str)
    end
  end

  class Parameter
    attr_reader :io_type
    attr_reader :name
    attr_reader :qname
    attr_reader :mapped_class

    def initialize(io_type, name, qname, mapped_class)
      @io_type = io_type
      @name = name
      @qname = qname
      @mapped_class = mapped_class
    end
  end
end


end
end
