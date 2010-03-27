# SOAP4R - WEBrick HTTP Server
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'logger'
require 'soap/attrproxy'
require 'soap/rpc/soaplet'
require 'soap/streamHandler'
require 'webrick'


module SOAP
module RPC


class HTTPServer < Logger::Application
  include AttrProxy

  attr_reader :server
  attr_accessor :default_namespace

  attr_proxy :mapping_registry, true
  attr_proxy :literal_mapping_registry, true
  attr_proxy :generate_explicit_type, true
  attr_proxy :use_default_namespace, true

  def initialize(config)
    actor = config[:SOAPHTTPServerApplicationName] || self.class.name
    super(actor)
    @default_namespace = config[:SOAPDefaultNamespace]
    @webrick_config = config.dup
    self.level = Logger::Severity::ERROR # keep silent by default
    @webrick_config[:Logger] ||= @log
    @log = @webrick_config[:Logger]     # sync logger of App and HTTPServer
    @router = ::SOAP::RPC::Router.new(actor)
    @soaplet = ::SOAP::RPC::SOAPlet.new(@router)
    on_init
    @server = WEBrick::HTTPServer.new(@webrick_config)
    @server.mount('/soaprouter', @soaplet)
    if wsdldir = config[:WSDLDocumentDirectory]
      @server.mount('/wsdl', WEBrick::HTTPServlet::FileHandler, wsdldir)
    end
    @server.mount('/', @soaplet)
  end

  def on_init
    # do extra initialization in a derived class if needed.
  end

  def status
    @server.status if @server
  end

  def shutdown
    @server.shutdown if @server
  end

  def authenticator
    @soaplet.authenticator
  end

  def authenticator=(authenticator)
    @soaplet.authenticator = authenticator
  end

  # servant entry interface

  def add_rpc_request_servant(factory, namespace = @default_namespace)
    @router.add_rpc_request_servant(factory, namespace)
  end

  def add_rpc_servant(obj, namespace = @default_namespace)
    @router.add_rpc_servant(obj, namespace)
  end
  
  def add_request_headerhandler(factory)
    @router.add_request_headerhandler(factory)
  end

  def add_headerhandler(obj)
    @router.add_headerhandler(obj)
  end
  alias add_rpc_headerhandler add_headerhandler

  def filterchain
    @router.filterchain
  end

  # method entry interface

  def add_rpc_method(obj, name, *param)
    add_rpc_method_as(obj, name, name, *param)
  end
  alias add_method add_rpc_method

  def add_rpc_method_as(obj, name, name_as, *param)
    qname = XSD::QName.new(@default_namespace, name_as)
    soapaction = nil
    param_def = SOAPMethod.derive_rpc_param_def(obj, name, *param)
    @router.add_rpc_operation(obj, qname, soapaction, name, param_def)
  end
  alias add_method_as add_rpc_method_as

  def add_document_method(obj, soapaction, name, req_qnames, res_qnames)
    param_def = SOAPMethod.create_doc_param_def(req_qnames, res_qnames)
    @router.add_document_operation(obj, soapaction, name, param_def)
  end

  def add_rpc_operation(receiver, qname, soapaction, name, param_def, opt = {})
    @router.add_rpc_operation(receiver, qname, soapaction, name, param_def, opt)
  end

  def add_rpc_request_operation(factory, qname, soapaction, name, param_def, opt = {})
    @router.add_rpc_request_operation(factory, qname, soapaction, name, param_def, opt)
  end

  def add_document_operation(receiver, soapaction, name, param_def, opt = {})
    @router.add_document_operation(receiver, soapaction, name, param_def, opt)
  end

  def add_document_request_operation(factory, soapaction, name, param_def, opt = {})
    @router.add_document_request_operation(factory, soapaction, name, param_def, opt)
  end

private

  def attrproxy
    @router
  end

  def run
    @server.start
  end
end


end
end
