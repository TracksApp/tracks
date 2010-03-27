# SOAP4R - SOAP WSDL driver
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'soap/ruby18ext'
require 'wsdl/parser'
require 'wsdl/importer'
require 'xsd/qname'
require 'xsd/codegen/gensupport'
require 'soap/attrproxy'
require 'soap/mapping/wsdlencodedregistry'
require 'soap/mapping/wsdlliteralregistry'
require 'soap/rpc/driver'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/classNameCreator'


module SOAP


class WSDLDriverFactory
  include WSDL::SOAP::ClassDefCreatorSupport

  class FactoryError < StandardError; end

  attr_reader :wsdl

  def initialize(wsdl)
    @wsdl = import(wsdl)
  end
  
  def inspect
    sprintf("#<%s:%s:0x%x\n\n%s>", self.class.name, @wsdl.name, __id__, dump_method_signatures)
  end

  def create_rpc_driver(servicename = nil, portname = nil)
    port = find_port(servicename, portname)
    drv = SOAP::RPC::Driver.new(port.soap_address.location)
    if binding = port.find_binding
      init_driver(drv, binding)
      add_operation(drv, binding)
    end
    drv
  end

  def dump_method_signatures(servicename = nil, portname = nil)
    targetservice = XSD::QName.new(@wsdl.targetnamespace, servicename) if servicename
    targetport = XSD::QName.new(@wsdl.targetnamespace, portname) if portname
    sig = []
    element_definitions = @wsdl.collect_elements
    @wsdl.services.each do |service|
      next if targetservice and service.name != targetservice
      service.ports.each do |port|
        next if targetport and port.name != targetport
        if porttype = port.porttype
          assigned_method = collect_assigned_method(porttype.name)
          if binding = port.porttype.find_binding
            sig << binding.operations.collect { |op_bind|
              operation = op_bind.find_operation
              name = assigned_method[op_bind.boundid] || op_bind.name
              str = "= #{safemethodname(name)}\n\n"
              str << dump_method_signature(name, operation, element_definitions)
              str.gsub(/^#/, " ")
            }.join("\n")
          end
        end
      end
    end
    sig.join("\n")
  end

private

  def collect_assigned_method(porttypename)
    name_creator = WSDL::SOAP::ClassNameCreator.new
    methoddefcreator =
      WSDL::SOAP::MethodDefCreator.new(@wsdl, name_creator, nil, {})
    methoddefcreator.dump(porttypename)
    methoddefcreator.assigned_method
  end

  def find_port(servicename = nil, portname = nil)
    service = port = nil
    if servicename
      service = @wsdl.service(
        XSD::QName.new(@wsdl.targetnamespace, servicename))
    else
      service = @wsdl.services[0]
    end
    if service.nil?
      raise FactoryError.new("service #{servicename} not found in WSDL")
    end
    if portname
      port = service.ports[XSD::QName.new(@wsdl.targetnamespace, portname)]
      if port.nil?
        raise FactoryError.new("port #{portname} not found in WSDL")
      end
    else
      port = service.ports.find { |port| !port.soap_address.nil? }
      if port.nil?
        raise FactoryError.new("no ports have soap:address")
      end
    end
    if port.soap_address.nil?
      raise FactoryError.new("soap:address element not found in WSDL")
    end
    port
  end

  def init_driver(drv, binding)
    wsdl_elements = @wsdl.collect_elements
    wsdl_types = @wsdl.collect_complextypes + @wsdl.collect_simpletypes
    rpc_decode_typemap = wsdl_types +
      @wsdl.soap_rpc_complextypes(binding)
    drv.proxy.mapping_registry =
      Mapping::WSDLEncodedRegistry.new(rpc_decode_typemap)
    drv.proxy.literal_mapping_registry =
      Mapping::WSDLLiteralRegistry.new(wsdl_types, wsdl_elements)
  end

  def add_operation(drv, binding)
    name_creator = WSDL::SOAP::ClassNameCreator.new
    modulepath = 'WSDLDriverFactory'
    methoddefcreator =
      WSDL::SOAP::MethodDefCreator.new(@wsdl, name_creator, modulepath, {})
    mdefs = methoddefcreator.create(binding.name)
    if mdefs.nil?
      raise FactoryError.new("no method definition found in WSDL")
    end
    mdefs.each do |mdef|
      opt = {
        :request_style => mdef.style,
        :response_style => mdef.style,
        :request_use => mdef.inputuse,
        :response_use => mdef.outputuse
      }
      qname = mdef.qname
      soapaction = mdef.soapaction
      name = mdef.name
      if mdef.style == :rpc
        drv.add_rpc_operation(qname, soapaction, name, mdef.parameters, opt)
      else
        drv.add_document_operation(soapaction, name, mdef.parameters, opt)
      end
      orgname = mdef.qname.name
      if orgname != name and orgname.capitalize == name.capitalize
        ::SOAP::Mapping.define_singleton_method(drv, orgname) do |*arg|
          __send__(name, *arg)
        end
      end
    end
  end

  def import(location)
    WSDL::Importer.import(location)
  end
end


end
