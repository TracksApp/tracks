# WSDL4R - Creating driver code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'xsd/codegen'


module WSDL
module SOAP


class DriverCreator
  include ClassDefCreatorSupport

  attr_reader :definitions
  attr_accessor :drivername_postfix

  def initialize(definitions, name_creator, modulepath = nil)
    @definitions = definitions
    @name_creator = name_creator
    @modulepath = modulepath
    @drivername_postfix = ''
  end

  def dump(porttype = nil)
    result = "require 'soap/rpc/driver'\n\n"
    if @modulepath
      @modulepath.each do |name|
        result << "module #{name}\n"
      end
      result << "\n"
    end
    if porttype.nil?
      @definitions.porttypes.each do |type|
	result << dump_porttype(type.name)
	result << "\n"
      end
    else
      result << dump_porttype(porttype)
    end
    if @modulepath
      result << "\n"
      @modulepath.each do |name|
        result << "end\n"
      end
    end
    result
  end

private

  def dump_porttype(porttype)
    drivername = porttype.name + @drivername_postfix
    qname = XSD::QName.new(porttype.namespace, drivername)
    class_name = mapped_class_basename(qname, @modulepath)
    defined_const = {}
    result = MethodDefCreator.new(@definitions, @name_creator, @modulepath, defined_const).dump(porttype)
    methoddef = result[:methoddef]
    binding = @definitions.bindings.find { |item| item.type == porttype }
    if binding.nil? or binding.soapbinding.nil?
      # not bind or not a SOAP binding
      return ''
    end
    address = @definitions.porttype(porttype).locations[0]

    c = XSD::CodeGen::ClassDef.new(class_name, "::SOAP::RPC::Driver")
    c.def_const("DefaultEndpointUrl", ndq(address))
    c.def_code <<-EOD
Methods = [
#{methoddef.gsub(/^/, "  ")}
]
    EOD
    wsdl_name = @definitions.name ? @definitions.name.name : 'default'
    mrname = safeconstname(wsdl_name + 'MappingRegistry')
    c.def_method("initialize", "endpoint_url = nil") do
      %Q[endpoint_url ||= DefaultEndpointUrl\n] +
      %Q[super(endpoint_url, nil)\n] +
      %Q[self.mapping_registry = #{mrname}::EncodedRegistry\n] +
      %Q[self.literal_mapping_registry = #{mrname}::LiteralRegistry\n] +
      %Q[init_methods]
    end
    c.def_privatemethod("init_methods") do
      <<-EOD
        Methods.each do |definitions|
          opt = definitions.last
          if opt[:request_style] == :document
            add_document_operation(*definitions)
          else
            add_rpc_operation(*definitions)
            qname = definitions[0]
            name = definitions[2]
            if qname.name != name and qname.name.capitalize == name.capitalize
              ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
                __send__(name, *arg)
              end
            end
          end
        end
      EOD
    end
    defined_const.each do |ns, tag|
      c.def_const(tag, dq(ns))
    end
    c.dump
  end
end


end
end
