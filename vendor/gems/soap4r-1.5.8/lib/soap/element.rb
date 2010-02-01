# SOAP4R - SOAP elements library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/qname'
require 'soap/baseData'


module SOAP


###
## SOAP elements
#
module SOAPEnvelopeElement; end

class SOAPFault < SOAPStruct
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  def faultcode
    self['faultcode']
  end

  def faultstring
    self['faultstring']
  end

  def faultactor
    self['faultactor']
  end

  def detail
    self['detail']
  end

  def faultcode=(rhs)
    self['faultcode'] = rhs
  end

  def faultstring=(rhs)
    self['faultstring'] = rhs
  end

  def faultactor=(rhs)
    self['faultactor'] = rhs
  end

  def detail=(rhs)
    self['detail'] = rhs
  end

  def initialize(faultcode = nil, faultstring = nil, faultactor = nil, detail = nil)
    super(EleFaultName)
    @elename = EleFaultName
    @encodingstyle = EncodingNamespace
    if faultcode
      self.faultcode = faultcode
      self.faultstring = faultstring
      self.faultactor = faultactor
      self.detail = detail
      self.faultcode.elename = EleFaultCodeName if self.faultcode
      self.faultstring.elename = EleFaultStringName if self.faultstring
      self.faultactor.elename = EleFaultActorName if self.faultactor
      self.detail.elename = EleFaultDetailName if self.detail
    end
    faultcode.parent = self if faultcode
    faultstring.parent = self if faultstring
    faultactor.parent = self if faultactor
    detail.parent = self if detail
  end

  def encode(generator, ns, attrs = {})
    Generator.assign_ns(attrs, ns, EnvelopeNamespace)
    Generator.assign_ns(attrs, ns, EncodingNamespace)
    attrs[ns.name(AttrEncodingStyleName)] = EncodingNamespace
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    yield(self.faultcode)
    yield(self.faultstring)
    yield(self.faultactor)
    yield(self.detail) if self.detail
    generator.encode_tag_end(name, true)
  end
end


class SOAPBody < SOAPStruct
  include SOAPEnvelopeElement

  attr_reader :is_fault

  def initialize(data = nil, is_fault = false)
    super(nil)
    @elename = EleBodyName
    @encodingstyle = nil
    if data
      if data.respond_to?(:to_xmlpart)
        data = SOAP::SOAPRawData.new(data)
      elsif defined?(::REXML) and data.is_a?(::REXML::Element)
        data = SOAP::SOAPRawData.new(SOAP::SOAPREXMLElementWrap.new(data))
      end
      if data.respond_to?(:elename)
        add(data.elename.name, data)
      else
        data.to_a.each do |datum|
          add(datum.elename.name, datum)
        end
      end
    end
    @is_fault = is_fault
  end

  def encode(generator, ns, attrs = {})
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    @data.each do |data|
      yield(data)
    end
    generator.encode_tag_end(name, @data.size > 0)
  end

  def root_node
    @data.each do |node|
      if node.root == 1
	return node
      end
    end
    # No specified root...
    @data.each do |node|
      if node.root != 0
	return node
      end
    end
    raise Parser::FormatDecodeError.new('no root element')
  end
end


class SOAPHeaderItem < XSD::NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  attr_accessor :element
  attr_accessor :mustunderstand
  attr_accessor :encodingstyle
  attr_accessor :actor

  def initialize(element, mustunderstand = true, encodingstyle = nil, actor = nil)
    super()
    @type = nil
    @element = element
    @mustunderstand = mustunderstand
    @encodingstyle = encodingstyle
    @actor = actor
    element.parent = self if element
    element.qualified = true
  end

  def encode(generator, ns, attrs = {})
    attrs.each do |key, value|
      @element.extraattr[key] = value
    end
    # to remove mustUnderstand attribute, set it to nil
    unless @mustunderstand.nil?
      @element.extraattr[AttrMustUnderstandName] = (@mustunderstand ? '1' : '0')
    end
    if @encodingstyle
      @element.extraattr[AttrEncodingStyleName] = @encodingstyle
    end
    unless @element.encodingstyle
      @element.encodingstyle = @encodingstyle
    end
    if @actor
      @element.extraattr[AttrActorName] = @actor
    end
    yield(@element)
  end
end


class SOAPHeader < SOAPStruct
  include SOAPEnvelopeElement

  attr_writer :force_encode

  def initialize
    super(nil)
    @elename = EleHeaderName
    @encodingstyle = nil
    @force_encode = false
  end

  def encode(generator, ns, attrs = {})
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    @data.each do |data|
      yield(data)
    end
    generator.encode_tag_end(name, @data.size > 0)
  end

  def add(name, value)
    actor = value.extraattr[AttrActorName]
    mu = value.extraattr[AttrMustUnderstandName]
    encstyle = value.extraattr[AttrEncodingStyleName]
    mu_value = mu.nil? ? nil : (mu == '1')
    # to remove mustUnderstand attribute, set it to nil
    item = SOAPHeaderItem.new(value, mu_value, encstyle, actor)
    super(name, item)
  end

  def length
    @data.length
  end
  alias size length

  def encode?
    @force_encode or length > 0
  end
end


class SOAPEnvelope < XSD::NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype

  attr_reader :header
  attr_reader :body
  attr_reader :external_content

  def initialize(header = nil, body = nil)
    super()
    @type = nil
    @elename = EleEnvelopeName
    @encodingstyle = nil
    @header = header
    @body = body
    @external_content = {}
    header.parent = self if header
    body.parent = self if body
  end

  def header=(header)
    header.parent = self
    @header = header
  end

  def body=(body)
    body.parent = self
    @body = body
  end

  def encode(generator, ns, attrs = {})
    Generator.assign_ns(attrs, ns, elename.namespace)
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    yield(@header) if @header and @header.encode?
    yield(@body)
    generator.encode_tag_end(name, true)
  end

  def to_ary
    [header, body]
  end
end


end
