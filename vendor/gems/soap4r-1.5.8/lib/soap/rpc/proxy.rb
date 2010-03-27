# SOAP4R - RPC Proxy library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/processor'
require 'soap/mapping'
require 'soap/mapping/literalregistry'
require 'soap/rpc/rpc'
require 'soap/rpc/element'
require 'soap/header/handlerset'
require 'soap/filter'
require 'soap/streamHandler'
require 'soap/mimemessage'


module SOAP
module RPC


class Proxy
  include SOAP

public

  attr_accessor :soapaction
  attr_accessor :mandatorycharset
  attr_accessor :allow_unqualified_element
  attr_accessor :default_encodingstyle
  attr_accessor :generate_explicit_type
  attr_accessor :use_default_namespace
  attr_accessor :return_response_as_xml
  attr_reader :headerhandler
  attr_reader :filterchain
  attr_reader :streamhandler

  attr_accessor :mapping_registry
  attr_accessor :literal_mapping_registry

  attr_reader :operation

  def initialize(endpoint_url, soapaction, options)
    @endpoint_url = endpoint_url
    @soapaction = soapaction
    @options = options
    @protocol_option = options["protocol"] ||= ::SOAP::Property.new
    initialize_streamhandler(@protocol_option)
    @operation = {}
    @operation_by_qname = {}
    @operation_by_soapaction = {}
    @mandatorycharset = nil
    # TODO: set to false by default or drop thie option in 1.6.0
    @allow_unqualified_element = true
    @default_encodingstyle = nil
    @generate_explicit_type = nil
    @use_default_namespace = false
    @return_response_as_xml = false
    @headerhandler = Header::HandlerSet.new
    @filterchain = Filter::FilterChain.new
    @mapping_registry = nil
    @literal_mapping_registry = ::SOAP::Mapping::LiteralRegistry.new
  end

  def inspect
    "#<#{self.class}:#{@endpoint_url}>"
  end

  def endpoint_url
    @endpoint_url
  end

  def endpoint_url=(endpoint_url)
    @endpoint_url = endpoint_url
    reset_stream
  end

  def reset_stream
    @streamhandler.reset(@endpoint_url)
  end

  def set_wiredump_file_base(wiredump_file_base)
    @streamhandler.wiredump_file_base = wiredump_file_base
  end

  def test_loopback_response
    @streamhandler.test_loopback_response
  end

  def add_rpc_operation(qname, soapaction, name, param_def, opt = {})
    ensure_styleuse_option(opt, :rpc, :encoded)
    opt[:request_qname] = qname
    op = Operation.new(soapaction, param_def, opt)
    assign_operation(name, qname, soapaction, op)
  end

  def add_document_operation(soapaction, name, param_def, opt = {})
    ensure_styleuse_option(opt, :document, :literal)
    op = Operation.new(soapaction, param_def, opt)
    assign_operation(name, nil, soapaction, op)
  end

  # add_method is for shortcut of typical rpc/encoded method definition.
  alias add_method add_rpc_operation
  alias add_rpc_method add_rpc_operation
  alias add_document_method add_document_operation

  def invoke(req_header, req_body, opt = nil)
    opt ||= create_encoding_opt
    env = route(req_header, req_body, opt, opt)
    if @return_response_as_xml
      opt[:response_as_xml]
    else
      env
    end
  end

  def call(name, *params)
    # name must be used only for lookup
    op_info = lookup_operation(name)
    mapping_opt = create_mapping_opt
    req_header = create_request_header
    req_body = SOAPBody.new(
      op_info.request_body(params, @mapping_registry,
        @literal_mapping_registry, mapping_opt)
    )
    reqopt = create_encoding_opt(
      :soapaction => op_info.soapaction || @soapaction,
      :envelopenamespace => @options["soap.envelope.requestnamespace"],
      :default_encodingstyle =>
        @default_encodingstyle || op_info.request_default_encodingstyle,
      :use_default_namespace =>
        op_info.use_default_namespace || @use_default_namespace
    )
    resopt = create_encoding_opt(
      :envelopenamespace => @options["soap.envelope.responsenamespace"],
      :default_encodingstyle =>
        @default_encodingstyle || op_info.response_default_encodingstyle
    )
    if reqopt[:generate_explicit_type].nil?
      reqopt[:generate_explicit_type] = (op_info.request_use == :encoded)
    end
    if resopt[:generate_explicit_type].nil?
      resopt[:generate_explicit_type] = (op_info.response_use == :encoded)
    end
    env = route(req_header, req_body, reqopt, resopt)
    if op_info.response_use.nil?
      return nil
    end
    raise EmptyResponseError unless env
    receive_headers(env.header)
    begin
      check_fault(env.body)
    rescue ::SOAP::FaultError => e
      op_info.raise_fault(e, @mapping_registry, @literal_mapping_registry)
    end
    if @return_response_as_xml
      resopt[:response_as_xml]
    else
      op_info.response_obj(env.body, @mapping_registry,
        @literal_mapping_registry, mapping_opt)
    end
  end

  def route(req_header, req_body, reqopt, resopt)
    req_env = ::SOAP::SOAPEnvelope.new(req_header, req_body)
    unless reqopt[:envelopenamespace].nil?
      set_envelopenamespace(req_env, reqopt[:envelopenamespace])
    end
    reqopt[:external_content] = nil
    conn_data = marshal(req_env, reqopt)
    if ext = reqopt[:external_content]
      mime = MIMEMessage.new
      ext.each do |k, v|
      	mime.add_attachment(v.data)
      end
      mime.add_part(conn_data.send_string + "\r\n")
      mime.close
      conn_data.send_string = mime.content_str
      conn_data.send_contenttype = mime.headers['content-type'].str
    end
    conn_data.soapaction = reqopt[:soapaction]
    conn_data = @streamhandler.send(@endpoint_url, conn_data)
    if conn_data.receive_string.empty?
      return nil
    end
    unmarshal(conn_data, resopt)
  end

  def check_fault(body)
    if body.fault
      raise SOAP::FaultError.new(body.fault)
    end
  end

private

  def ensure_styleuse_option(opt, style, use)
    if opt[:request_style] || opt[:response_style] || opt[:request_use] || opt[:response_use]
      # do not edit
    else
      opt[:request_style] ||= style
      opt[:response_style] ||= style
      opt[:request_use] ||= use
      opt[:response_use] ||= use
    end
  end

  def initialize_streamhandler(options)
    value = options["streamhandler"]
    if value and !value.empty?
      factory = Property::Util.const_from_name(value)
    else
      factory = HTTPStreamHandler
    end
    @streamhandler = factory.create(options)
    options.add_hook("streamhandler") do |key, value|
      @streamhandler.reset
      if value.respond_to?(:create)
        factory = value
      elsif value and !value.to_str.empty?
        factory = Property::Util.const_from_name(value.to_str)
      else
        factory = HTTPStreamHandler
      end
      options.unlock(true)
      @streamhandler = factory.create(options)
    end
  end

  def set_envelopenamespace(env, namespace)
    env.elename = XSD::QName.new(namespace, env.elename.name)
    if env.header
      env.header.elename = XSD::QName.new(namespace, env.header.elename.name)
    end
    if env.body
      env.body.elename = XSD::QName.new(namespace, env.body.elename.name)
    end
  end

  def create_request_header
    header = ::SOAP::SOAPHeader.new
    items = @headerhandler.on_outbound(header)
    items.each do |item|
      header.add(item.elename.name, item)
    end
    header
  end

  def receive_headers(header)
    @headerhandler.on_inbound(header) if header
  end

  def marshal(env, opt)
    @filterchain.each do |filter|
      env = filter.on_outbound(env, opt)
      break unless env
    end
    send_string = Processor.marshal(env, opt)
    StreamHandler::ConnectionData.new(send_string)
  end

  def unmarshal(conn_data, opt)
    contenttype = conn_data.receive_contenttype
    xml = nil
    if /#{MIMEMessage::MultipartContentType}/i =~ contenttype
      opt[:external_content] = {}
      mime = MIMEMessage.parse("Content-Type: " + contenttype,
	conn_data.receive_string)
      mime.parts.each do |part|
	value = Attachment.new(part.content)
	value.contentid = part.contentid
	obj = SOAPAttachment.new(value)
	opt[:external_content][value.contentid] = obj if value.contentid
      end
      opt[:charset] = @mandatorycharset ||
	StreamHandler.parse_media_type(mime.root.headers['content-type'].str)
      xml = mime.root.content
    else
      opt[:charset] = @mandatorycharset ||
	::SOAP::StreamHandler.parse_media_type(contenttype)
      xml = conn_data.receive_string
    end
    @filterchain.reverse_each do |filter|
      xml = filter.on_inbound(xml, opt)
      break unless xml
    end
    env = Processor.unmarshal(xml, opt)
    if @return_response_as_xml
      opt[:response_as_xml] = xml
    end
    unless env.is_a?(::SOAP::SOAPEnvelope)
      raise ResponseFormatError.new("response is not a SOAP envelope: #{env}")
    end
    env
  end

  def create_encoding_opt(hash = nil)
    opt = {}
    opt[:default_encodingstyle] = @default_encodingstyle
    opt[:allow_unqualified_element] = @allow_unqualified_element
    opt[:generate_explicit_type] = @generate_explicit_type
    opt[:no_indent] = @options["soap.envelope.no_indent"]
    opt[:use_numeric_character_reference] =
      @options["soap.envelope.use_numeric_character_reference"]
    opt.update(hash) if hash
    opt
  end

  def create_mapping_opt(hash = nil)
    opt = {
      :external_ces => @options["soap.mapping.external_ces"]
    }
    opt.update(hash) if hash
    opt
  end

  def assign_operation(name, qname, soapaction, op)
    assigned = false
    if name and !name.empty?
      @operation[name] = op
      assigned = true
    end
    if qname
      @operation_by_qname[qname] = op
      assigned = true
    end
    if soapaction and !soapaction.empty?
      @operation_by_soapaction[soapaction] = op
      assigned = true
    end
    unless assigned
      raise MethodDefinitionError.new("cannot assign operation")
    end
  end

  def lookup_operation(name_or_qname_or_soapaction)
    if op = @operation[name_or_qname_or_soapaction]
      return op
    end
    if op = @operation_by_qname[name_or_qname_or_soapaction]
      return op
    end
    if op = @operation_by_soapaction[name_or_qname_or_soapaction]
      return op
    end
    raise MethodDefinitionError.new(
      "operation: #{name_or_qname_or_soapaction} not supported")
  end

  class Operation
    attr_reader :soapaction
    attr_reader :request_style
    attr_reader :response_style
    attr_reader :request_use
    attr_reader :response_use
    attr_reader :use_default_namespace

    def initialize(soapaction, param_def, opt)
      @soapaction = soapaction
      @request_style = opt[:request_style]
      @response_style = opt[:response_style]
      @request_use = opt[:request_use]
      @response_use = opt[:response_use]
      @use_default_namespace =
        opt[:use_default_namespace] || opt[:elementformdefault]
      if opt.key?(:elementformdefault)
        warn("option :elementformdefault is deprecated.  use :use_default_namespace instead")
      end
      check_style(@request_style)
      check_style(@response_style)
      check_use(@request_use)
      check_use(@response_use)
      if @request_style == :rpc
        @rpc_request_qname = opt[:request_qname]
        if @rpc_request_qname.nil?
          raise MethodDefinitionError.new("rpc_request_qname must be given")
        end
        @rpc_method_factory =
          RPC::SOAPMethodRequest.new(@rpc_request_qname, param_def, @soapaction)
      else
        @doc_request_qnames = []
        @doc_response_qnames = []
        param_def.each do |param|
          param = MethodDef.to_param(param)
          case param.io_type
          when SOAPMethod::IN
            @doc_request_qnames << param.qname
          when SOAPMethod::OUT
            @doc_response_qnames << param.qname
          else
            raise MethodDefinitionError.new(
              "illegal inout definition for document style: #{param.io_type}")
          end
        end
      end
    end

    def request_default_encodingstyle
      (@request_use == :encoded) ? EncodingNamespace : LiteralNamespace
    end

    def response_default_encodingstyle
      (@response_use == :encoded) ? EncodingNamespace : LiteralNamespace
    end

    def request_body(values, mapping_registry, literal_mapping_registry, opt)
      if @request_style == :rpc
        request_rpc(values, mapping_registry, literal_mapping_registry, opt)
      else
        request_doc(values, mapping_registry, literal_mapping_registry, opt)
      end
    end

    def response_obj(body, mapping_registry, literal_mapping_registry, opt)
      if @response_style == :rpc
        response_rpc(body, mapping_registry, literal_mapping_registry, opt)
      else
        unique_result_for_one_element_array(
          response_doc(body, mapping_registry, literal_mapping_registry, opt))
      end
    end

    def raise_fault(e, mapping_registry, literal_mapping_registry)
      if @response_style == :rpc
        Mapping.fault2exception(e, mapping_registry)
      else
        Mapping.fault2exception(e, literal_mapping_registry)
      end
    end

  private

    # nil for [] / 1 for [1] / [1, 2] for [1, 2]
    def unique_result_for_one_element_array(ary)
      ary.size <= 1 ? ary[0] : ary
    end

    def check_style(style)
      unless [:rpc, :document].include?(style)
        raise MethodDefinitionError.new("unknown style: #{style}")
      end
    end

    # nil means oneway
    def check_use(use)
      unless [:encoded, :literal, nil].include?(use)
        raise MethodDefinitionError.new("unknown use: #{use}")
      end
    end

    def request_rpc(values, mapping_registry, literal_mapping_registry, opt)
      if @request_use == :encoded
        request_rpc_enc(values, mapping_registry, opt)
      else
        request_rpc_lit(values, literal_mapping_registry, opt)
      end
    end

    def request_doc(values, mapping_registry, literal_mapping_registry, opt)
      if @request_use == :encoded
        request_doc_enc(values, mapping_registry, opt)
      else
        request_doc_lit(values, literal_mapping_registry, opt)
      end
    end

    def request_rpc_enc(values, mapping_registry, opt)
      method = @rpc_method_factory.dup
      names = method.input_params
      types = method.input_param_types
      ary = Mapping.objs2soap(values, mapping_registry, types, opt)
      soap = {}
      0.upto(ary.length - 1) do |idx|
        soap[names[idx]] = ary[idx]
      end
      method.set_param(soap)
      method
    end

    def request_rpc_lit(values, mapping_registry, opt)
      method = @rpc_method_factory.dup
      names = method.input_params
      types = method.get_paramtypes(names)
      params = {}
      idx = 0
      names.each do |name|
        params[name] = Mapping.obj2soap(values[idx], mapping_registry, 
          types[idx], opt)
        params[name].elename = XSD::QName.new(nil, name)
        idx += 1
      end
      method.set_param(params)
      method
    end

    def request_doc_enc(values, mapping_registry, opt)
      (0...values.size).collect { |idx|
        ele = Mapping.obj2soap(values[idx], mapping_registry, nil, opt)
        ele.elename = @doc_request_qnames[idx]
        ele
      }
    end

    def request_doc_lit(values, mapping_registry, opt)
      (0...values.size).collect { |idx|
        ele = Mapping.obj2soap(values[idx], mapping_registry,
          @doc_request_qnames[idx], opt)
        ele.encodingstyle = LiteralNamespace
        ele
      }
    end

    def response_rpc(body, mapping_registry, literal_mapping_registry, opt)
      if @response_use == :encoded
        response_rpc_enc(body, mapping_registry, opt)
      else
        response_rpc_lit(body, literal_mapping_registry, opt)
      end
    end

    def response_doc(body, mapping_registry, literal_mapping_registry, opt)
      if @response_use == :encoded
        response_doc_enc(body, mapping_registry, opt)
      else
        response_doc_lit(body, literal_mapping_registry, opt)
      end
    end

    def response_rpc_enc(body, mapping_registry, opt)
      ret = nil
      if body.response
        ret = Mapping.soap2obj(body.response, mapping_registry,
          @rpc_method_factory.retval_class_name, opt)
      end
      if body.outparams
        outparams = body.outparams.collect { |outparam|
          Mapping.soap2obj(outparam, mapping_registry, nil, opt)
        }
        [ret].concat(outparams)
      else
        ret
      end
    end

    def response_rpc_lit(body, mapping_registry, opt)
      body.root_node.collect { |key, value|
        Mapping.soap2obj(value, mapping_registry,
          @rpc_method_factory.retval_class_name, opt)
      }
    end

    def response_doc_enc(body, mapping_registry, opt)
      body.collect { |key, value|
        Mapping.soap2obj(value, mapping_registry, nil, opt)
      }
    end

    def response_doc_lit(body, mapping_registry, opt)
      body.collect { |key, value|
        Mapping.soap2obj(value, mapping_registry)
      }
    end
  end
end


end
end
