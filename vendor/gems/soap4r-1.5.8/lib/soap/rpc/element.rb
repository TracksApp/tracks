# SOAP4R - RPC element definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'


module SOAP

# Add method definitions for RPC to common definition in element.rb
class SOAPBody < SOAPStruct
  public

  def request
    root_node
  end

  def response
    root = root_node
    if !@is_fault
      if root.nil?
        nil
      elsif root.is_a?(SOAPBasetype)
        root
      else
        # Initial element is [retval].
        root[0]
      end
    else
      root
    end
  end

  def outparams
    root = root_node
    if !@is_fault and !root.nil? and !root.is_a?(SOAPBasetype)
      op = root[1..-1]
      op = nil if op && op.empty?
      op
    else
      nil
    end
  end

  def fault
    if @is_fault
      self['fault']
    else
      nil
    end
  end

  def fault=(fault)
    @is_fault = true
    add('fault', fault)
  end
end


module RPC


class RPCError < Error; end
class MethodDefinitionError < RPCError; end
class ParameterError < RPCError; end

class SOAPMethod < SOAPStruct
  RETVAL = 'retval'
  IN = 'in'
  OUT = 'out'
  INOUT = 'inout'

  attr_reader :param_def
  attr_reader :inparam
  attr_reader :outparam
  attr_reader :retval_name
  attr_reader :retval_class_name

  def initialize(qname, param_def = nil)
    super(nil)
    @elename = qname
    @encodingstyle = nil

    @param_def = param_def

    @signature = []
    @inparam_names = []
    @inoutparam_names = []
    @outparam_names = []

    @inparam = {}
    @outparam = {}
    @retval_name = nil
    @retval_class_name = nil

    init_param(@param_def) if @param_def
  end

  def have_member
    true
  end

  def have_outparam?
    @outparam_names.size > 0
  end

  def input_params
    collect_params(IN, INOUT)
  end

  def output_params
    collect_params(OUT, INOUT)
  end

  def input_param_types
    collect_param_types(IN, INOUT)
  end

  def output_param_types
    collect_param_types(OUT, INOUT)
  end

  def set_param(params)
    params.each do |param, data|
      @inparam[param] = data
      data.elename = XSD::QName.new(data.elename.namespace, param)
      data.parent = self
    end
  end

  def set_outparam(params)
    params.each do |param, data|
      @outparam[param] = data
      data.elename = XSD::QName.new(data.elename.namespace, param)
    end
  end

  def get_paramtypes(names)
    types = []
    @signature.each do |io_type, name, type_qname|
      if type_qname && idx = names.index(name)
        types[idx] = type_qname
      end
    end
    types
  end

  def SOAPMethod.param_count(param_def, *type)
    count = 0
    param_def.each do |io_type, name, param_type|
      if type.include?(io_type)
        count += 1
      end
    end
    count
  end

  def SOAPMethod.derive_rpc_param_def(obj, name, *param)
    if param.size == 1 and param[0].is_a?(Array)
      return param[0]
    end
    if param.empty?
      method = obj.method(name)
      param_names = (1..method.arity.abs).collect { |i| "p#{i}" }
    else
      param_names = param
    end
    create_rpc_param_def(param_names)
  end

  def SOAPMethod.create_rpc_param_def(param_names)
    param_def = []
    param_names.each do |param_name|
      param_def.push([IN, param_name, nil])
    end
    param_def.push([RETVAL, 'return', nil])
    param_def
  end

  def SOAPMethod.create_doc_param_def(req_qnames, res_qnames)
    req_qnames = [req_qnames] if req_qnames.is_a?(XSD::QName)
    res_qnames = [res_qnames] if res_qnames.is_a?(XSD::QName)
    param_def = []
    # req_qnames and res_qnames can be nil
    if req_qnames
      req_qnames.each do |qname|
        param_def << [IN, qname.name, [nil, qname.namespace, qname.name]]
      end
    end
    if res_qnames
      res_qnames.each do |qname|
        param_def << [OUT, qname.name, [nil, qname.namespace, qname.name]]
      end
    end
    param_def
  end

private

  def collect_param_types(*type)
    names = []
    @signature.each do |io_type, name, type_qname|
      names << type_qname if type.include?(io_type)
    end
    names
  end

  def collect_params(*type)
    names = []
    @signature.each do |io_type, name, type_qname|
      names << name if type.include?(io_type)
    end
    names
  end

  def init_param(param_def)
    param_def.each do |io_type, name, param_type|
      mapped_class, nsdef, namedef = SOAPMethod.parse_param_type(param_type)
      if nsdef && namedef
        type_qname = XSD::QName.new(nsdef, namedef)
      elsif mapped_class
        type_qname = TypeMap.index(mapped_class)
      end
      case io_type
      when IN
        @signature.push([IN, name, type_qname])
        @inparam_names.push(name)
      when OUT
        @signature.push([OUT, name, type_qname])
        @outparam_names.push(name)
      when INOUT
        @signature.push([INOUT, name, type_qname])
        @inoutparam_names.push(name)
      when RETVAL
        if @retval_name
          raise MethodDefinitionError.new('duplicated retval')
        end
        @retval_name = name
        @retval_class_name = mapped_class
      else
        raise MethodDefinitionError.new("unknown type: #{io_type}")
      end
    end
  end

  def self.parse_param_type(param_type)
    mapped_class, nsdef, namedef = param_type
    # the first element of typedef in param_def can be a String like
    # "::SOAP::SOAPStruct" or "CustomClass[]".  turn this String to a class if
    # we can.
    if mapped_class.is_a?(String)
      if /\[\]\Z/ =~ mapped_class
        # when '[]' is added, ignore this.
        mapped_class = nil
      else
        mapped_class = Mapping.class_from_name(mapped_class)
      end
    end
    [mapped_class, nsdef, namedef]
  end
end


class SOAPMethodRequest < SOAPMethod
  attr_accessor :soapaction

  def SOAPMethodRequest.create_request(qname, *params)
    param_def = []
    param_value = []
    i = 0
    params.each do |param|
      param_name = "p#{i}"
      i += 1
      param_def << [IN, param_name, nil]
      param_value << [param_name, param]
    end
    param_def << [RETVAL, 'return', nil]
    o = new(qname, param_def)
    o.set_param(param_value)
    o
  end

  def initialize(qname, param_def = nil, soapaction = nil)
    super(qname, param_def)
    @soapaction = soapaction
  end

  def each
    input_params.each do |name|
      unless @inparam[name]
        raise ParameterError.new("parameter: #{name} was not given")
      end
      yield(name, @inparam[name])
    end
  end

  def dup
    req = self.class.new(@elename.dup, @param_def, @soapaction)
    req.encodingstyle = @encodingstyle
    req
  end

  def create_method_response(response_name = nil)
    response_name ||=
      XSD::QName.new(@elename.namespace, @elename.name + 'Response')
    SOAPMethodResponse.new(response_name, @param_def)
  end
end


class SOAPMethodResponse < SOAPMethod

  def initialize(qname, param_def = nil)
    super(qname, param_def)
    @retval = nil
  end

  def retval
    @retval
  end

  def retval=(retval)
    @retval = retval
    @retval.elename = @retval.elename.dup_name(@retval_name || 'return')
    retval.parent = self
    retval
  end

  def each
    if @retval_name and !@retval.is_a?(SOAPVoid)
      yield(@retval_name, @retval)
    end

    output_params.each do |name|
      unless @outparam[name]
        raise ParameterError.new("parameter: #{name} was not given")
      end
      yield(name, @outparam[name])
    end
  end
end


# To return(?) void explicitly.
#  def foo(input_var)
#    ...
#    return SOAP::RPC::SOAPVoid.new
#  end
class SOAPVoid < XSD::XSDAnySimpleType
  include SOAPBasetype
  extend SOAPModuleUtils
  Name = XSD::QName.new(Mapping::RubyCustomTypeNamespace, nil)

public
  def initialize()
    @elename = Name
    @id = nil
    @precedents = []
    @parent = nil
  end
end


end
end
