# soap/baseData.rb: SOAP4R - Base type library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/datatypes'
require 'soap/soap'
require 'xsd/codegen/gensupport'
require 'soap/mapping/mapping'


module SOAP


###
## Mix-in module for SOAP base type classes.
#
module SOAPModuleUtils
  include SOAP

public

  def decode(elename)
    d = self.new
    d.elename = elename
    d
  end

  def to_data(str)
    new(str).data
  end
end


###
## for SOAP type(base and compound)
#
module SOAPType
  attr_accessor :encodingstyle
  attr_accessor :elename
  attr_accessor :id
  attr_reader :precedents
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position
  attr_reader :extraattr
  attr_accessor :definedtype
  attr_accessor :force_typed

  def initialize(*arg)
    super
    @encodingstyle = nil
    @elename = XSD::QName::EMPTY
    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @position = nil
    @definedtype = nil
    @extraattr = {}
    @force_typed = false
  end

  def inspect
    if self.is_a?(XSD::NSDBase)
      sprintf("#<%s:0x%x %s %s>", self.class.name, __id__, self.elename, self.type)
    else
      sprintf("#<%s:0x%x %s>", self.class.name, __id__, self.elename)
    end
  end

  def rootnode
    node = self
    while node = node.parent
      break if SOAPEnvelope === node
    end
    node
  end
end


###
## for SOAP base type
#
module SOAPBasetype
  include SOAPType
  include SOAP

  attr_accessor :qualified

  def initialize(*arg)
    super
    @qualified = nil
  end
end


###
## for SOAP compound type
#
module SOAPCompoundtype
  include SOAPType
  include SOAP

  attr_accessor :qualified

  def initialize(*arg)
    super
    @qualified = nil
  end
end

# marker for compound types which have named accessor
module SOAPNameAccessible
end


###
## Convenience datatypes.
#
class SOAPReference < XSD::NSDBase
  include SOAPBasetype
  extend SOAPModuleUtils

public

  attr_accessor :refid

  # Override the definition in SOAPBasetype.
  def initialize(obj = nil)
    super()
    @type = XSD::QName::EMPTY
    @refid = nil
    @obj = nil
    __setobj__(obj) if obj
  end

  def __getobj__
    @obj
  end

  def __setobj__(obj)
    @obj = obj
    @refid = @obj.id || SOAPReference.create_refid(@obj)
    @obj.id = @refid unless @obj.id
    @obj.precedents << self
    # Copies NSDBase information
    @obj.type = @type unless @obj.type
  end

  # Why don't I use delegate.rb?
  # -> delegate requires target object type at initialize time.
  # Why don't I use forwardable.rb?
  # -> forwardable requires a list of forwarding methods.
  #
  # ToDo: Maybe I should use forwardable.rb and give it a methods list like
  # delegate.rb...
  #
  def method_missing(msg_id, *params)
    if @obj
      @obj.send(msg_id, *params)
    else
      nil
    end
  end

  # for referenced base type such as a long value from Axis.
  # base2obj requires a node to respond to :data
  def data
    if @obj.respond_to?(:data)
      @obj.data
    end
  end

  def refidstr
    '#' + @refid
  end

  def self.create_refid(obj)
    'id' + obj.__id__.to_s
  end

  def self.decode(elename, refidstr)
    if /\A#(.*)\z/ =~ refidstr
      refid = $1
    elsif /\Acid:(.*)\z/ =~ refidstr
      refid = $1
    else
      raise ArgumentError.new("illegal refid #{refidstr}")
    end
    d = super(elename)
    d.refid = refid
    d
  end
end


class SOAPExternalReference < XSD::NSDBase
  include SOAPBasetype
  extend SOAPModuleUtils

  def initialize
    super()
    @type = XSD::QName::EMPTY
  end

  def referred
    rootnode.external_content[external_contentid] = self
  end

  def refidstr
    'cid:' + external_contentid
  end

private

  def external_contentid
    raise NotImplementedError.new
  end
end


class SOAPNil < XSD::XSDNil
  include SOAPBasetype
  extend SOAPModuleUtils

public

  def initialize(value = nil)
    super(value)
    @extraattr[XSD::AttrNilName] = 'true'
  end
end

# SOAPRawString is for sending raw string.  In contrast to SOAPString,
# SOAP4R does not do XML encoding and does not convert its CES.  The string it
# holds is embedded to XML instance directly as a 'xsd:string'.
class SOAPRawString < XSD::XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
end


###
## Basic datatypes.
#
class SOAPAnySimpleType < XSD::XSDAnySimpleType
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPString < XSD::XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, StringLiteral)
end

class SOAPNormalizedString < XSD::XSDNormalizedString
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NormalizedStringLiteral)
end

class SOAPToken < XSD::XSDToken
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, TokenLiteral)
end

class SOAPLanguage < XSD::XSDLanguage
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, LanguageLiteral)
end

class SOAPNMTOKEN < XSD::XSDNMTOKEN
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NMTOKENLiteral)
end

class SOAPNMTOKENS < XSD::XSDNMTOKENS
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NMTOKENSLiteral)
end

class SOAPName < XSD::XSDName
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NameLiteral)
end

class SOAPNCName < XSD::XSDNCName
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NCNameLiteral)
end

class SOAPID < XSD::XSDID
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, IDLiteral)
end

class SOAPIDREF < XSD::XSDIDREF
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, IDREFLiteral)
end

class SOAPIDREFS < XSD::XSDIDREFS
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, IDREFSLiteral)
end

class SOAPENTITY < XSD::XSDENTITY
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, ENTITYLiteral)
end

class SOAPENTITIES < XSD::XSDENTITIES
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, ENTITIESLiteral)
end

class SOAPBoolean < XSD::XSDBoolean
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, BooleanLiteral)
end

class SOAPDecimal < XSD::XSDDecimal
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, DecimalLiteral)
end

class SOAPFloat < XSD::XSDFloat
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, FloatLiteral)
end

class SOAPDouble < XSD::XSDDouble
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, DoubleLiteral)
end

class SOAPDuration < XSD::XSDDuration
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, DurationLiteral)
end

class SOAPDateTime < XSD::XSDDateTime
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, DateTimeLiteral)
end

class SOAPTime < XSD::XSDTime
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, TimeLiteral)
end

class SOAPDate < XSD::XSDDate
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, DateLiteral)
end

class SOAPGYearMonth < XSD::XSDGYearMonth
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, GYearMonthLiteral)
end

class SOAPGYear < XSD::XSDGYear
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, GYearLiteral)
end

class SOAPGMonthDay < XSD::XSDGMonthDay
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, GMonthDayLiteral)
end

class SOAPGDay < XSD::XSDGDay
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, GDayLiteral)
end

class SOAPGMonth < XSD::XSDGMonth
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, GMonthLiteral)
end

class SOAPHexBinary < XSD::XSDHexBinary
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, HexBinaryLiteral)
end

class SOAPBase64 < XSD::XSDBase64Binary
  include SOAPBasetype
  extend SOAPModuleUtils
  Type = SOAPENCType = QName.new(EncodingNamespace, Base64Literal)

public

  def initialize(value = nil)
    super(value)
    @type = Type
  end

  def as_xsd
    @type = XSD::XSDBase64Binary::Type
  end
end

class SOAPAnyURI < XSD::XSDAnyURI
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, AnyURILiteral)
end

class SOAPQName < XSD::XSDQName
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, QNameLiteral)
end


class SOAPInteger < XSD::XSDInteger
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, IntegerLiteral)
end

class SOAPNonPositiveInteger < XSD::XSDNonPositiveInteger
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NonPositiveIntegerLiteral)
end

class SOAPNegativeInteger < XSD::XSDNegativeInteger
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NegativeIntegerLiteral)
end

class SOAPLong < XSD::XSDLong
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, LongLiteral)
end

class SOAPInt < XSD::XSDInt
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, IntLiteral)
end

class SOAPShort < XSD::XSDShort
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, ShortLiteral)
end

class SOAPByte < XSD::XSDByte
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, ByteLiteral)
end

class SOAPNonNegativeInteger < XSD::XSDNonNegativeInteger
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, NonNegativeIntegerLiteral)
end

class SOAPUnsignedLong < XSD::XSDUnsignedLong
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, UnsignedLongLiteral)
end

class SOAPUnsignedInt < XSD::XSDUnsignedInt
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, UnsignedIntLiteral)
end

class SOAPUnsignedShort < XSD::XSDUnsignedShort
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, UnsignedShortLiteral)
end

class SOAPUnsignedByte < XSD::XSDUnsignedByte
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, UnsignedByteLiteral)
end

class SOAPPositiveInteger < XSD::XSDPositiveInteger
  include SOAPBasetype
  extend SOAPModuleUtils
  SOAPENCType = QName.new(EncodingNamespace, PositiveIntegerLiteral)
end


###
## Compound datatypes.
#
class SOAPStruct < XSD::NSDBase
  include Enumerable
  include SOAPCompoundtype
  include SOAPNameAccessible

public

  def initialize(type = nil)
    super()
    @type = type || XSD::QName::EMPTY
    @array = []
    @data = []
  end

  def to_s
    str = ''
    self.each do |key, data|
      str << "#{key}: #{data}\n"
    end
    str
  end

  def add(name, value)
    value = SOAPNil.new if value.nil?
    @array.push(name)
    value.elename = value.elename.dup_name(name)
    @data.push(value)
    value.parent = self if value.respond_to?(:parent=)
    value
  end

  def [](idx)
    if idx.is_a?(Range)
      @data[idx]
    elsif idx.is_a?(Integer)
      if (idx > @array.size)
        raise ArrayIndexOutOfBoundsError.new('In ' << @type.name)
      end
      @data[idx]
    else
      if @array.include?(idx)
	@data[@array.index(idx)]
      else
	nil
      end
    end
  end

  def []=(idx, data)
    if @array.include?(idx)
      data.parent = self if data.respond_to?(:parent=)
      @data[@array.index(idx)] = data
    else
      add(idx, data)
    end
  end

  def key?(name)
    @array.include?(name)
  end

  def members
    @array
  end

  def have_member
    !@array.empty?
  end

  def to_obj
    hash = {}
    proptype = {}
    each do |k, v|
      value = v.respond_to?(:to_obj) ? v.to_obj : v.to_s
      case proptype[k]
      when :single
        hash[k] = [hash[k], value]
        proptype[k] = :multi
      when :multi
        hash[k] << value
      else
        hash[k] = value
        proptype[k] = :single
      end
    end
    hash
  end

  def each
    idx = 0
    while idx < @array.length
      yield(@array[idx], @data[idx])
      idx += 1
    end
  end

  def replace
    members.each do |member|
      self[member] = yield(self[member])
    end
  end

  def self.decode(elename, type)
    s = SOAPStruct.new(type)
    s.elename = elename
    s
  end
end


# SOAPElement is not typed so it is not derived from NSDBase.
class SOAPElement
  include Enumerable
  include SOAPCompoundtype
  include SOAPNameAccessible

  attr_accessor :type
  # Text interface.
  attr_accessor :text
  alias data text

  def initialize(elename, text = nil)
    super()
    if elename.nil?
      elename = XSD::QName::EMPTY
    else
      elename = Mapping.to_qname(elename)
    end
    @encodingstyle = LiteralNamespace
    @elename = elename
    @type = nil

    @array = []
    @data = []
    @text = text
  end

  def inspect
    sprintf("#<%s:0x%x %s>", self.class.name, __id__, self.elename) +
      (@text ? " #{@text.inspect}" : '') +
      @data.collect { |ele| "\n#{ele.inspect}" }.join.gsub(/^/, '  ')
  end

  def set(value)
    @text = value
  end

  # Element interfaces.
  def add(value)
    name = value.elename.name
    @array.push(name)
    @data.push(value)
    value.parent = self if value.respond_to?(:parent=)
    value
  end

  def [](idx)
    if @array.include?(idx)
      @data[@array.index(idx)]
    else
      nil
    end
  end

  def []=(idx, data)
    if @array.include?(idx)
      data.parent = self if data.respond_to?(:parent=)
      @data[@array.index(idx)] = data
    else
      add(data)
    end
  end

  def key?(name)
    @array.include?(name)
  end

  def members
    @array
  end

  def have_member
    !@array.empty?
  end

  def to_obj
    if !have_member
      @text
    else
      hash = {}
      proptype = {}
      each do |k, v|
        value = v.respond_to?(:to_obj) ? v.to_obj : v.to_s
        case proptype[k]
        when :single
          hash[k] = [hash[k], value]
          proptype[k] = :multi
        when :multi
          hash[k] << value
        else
          hash[k] = value
          proptype[k] = :single
        end
      end
      hash
    end
  end

  def each
    idx = 0
    while idx < @array.length
      yield(@array[idx], @data[idx])
      idx += 1
    end
  end

  def self.decode(elename)
    o = SOAPElement.new(elename)
    o
  end

  def self.from_objs(objs)
    objs.collect { |value|
      if value.is_a?(SOAPElement)
        value
      else
        k, v = value
        ele = from_obj(v)
        ele.elename = XSD::QName.new(nil, k)
        ele
      end
    }
  end

  # when obj is a Hash or an Array:
  #   when key starts with "xmlattr_":
  #     value is added as an XML attribute with the key name however the
  #     "xmlattr_" is dropped from the name.
  #   when key starts with "xmlele_":
  #     value is added as an XML element with the key name however the
  #     "xmlele_" is dropped from the name.
  #   if else:
  #     value is added as an XML element with the key name.
  def self.from_obj(obj, namespace = nil)
    return obj if obj.is_a?(SOAPElement)
    o = SOAPElement.new(nil)
    case obj
    when nil
      o.text = nil
    when Hash, Array
      obj.each do |name, value|
        addname, is_attr = parse_name(name, namespace)
        if value.is_a?(Array)
          value.each do |subvalue|
            if is_attr
              o.extraattr[addname] = subvalue
            else
              child = from_obj(subvalue, namespace)
              child.elename = addname
              o.add(child)
            end
          end
        else
          if is_attr
            o.extraattr[addname] = value
          else
            child = from_obj(value, namespace)
            child.elename = addname
            o.add(child)
          end
        end
      end
    else
      o.text = obj.to_s
    end
    o
  end

  def self.parse_name(obj, namespace = nil)
    qname = to_qname(obj, namespace)
    if /\Axmlele_/ =~ qname.name
      qname = XSD::QName.new(qname.namespace, qname.name.sub(/\Axmlele_/, ''))
      return qname, false
    elsif /\Axmlattr_/ =~ qname.name
      qname = XSD::QName.new(qname.namespace, qname.name.sub(/\Axmlattr_/, ''))
      return qname, true
    else
      return qname, false
    end
  end

  def self.to_qname(obj, namespace = nil)
    if obj.is_a?(XSD::QName)
      obj
    elsif /\A(.+):([^:]+)\z/ =~ obj.to_s
      XSD::QName.new($1, $2)
    else
      XSD::QName.new(namespace, obj.to_s)
    end
  end
end


class SOAPRawData < SOAPElement
  def initialize(obj)
    super(XSD::QName::EMPTY)
    @obj = obj
  end

  def to_xmlpart
    @obj.to_xmlpart
  end
end


class SOAPREXMLElementWrap
  def initialize(ele)
    @ele = ele
  end

  def to_xmlpart
    @ele.to_s
  end
end


class SOAPArray < XSD::NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  attr_accessor :sparse

  attr_reader :offset, :rank
  attr_accessor :size, :size_fixed
  attr_reader :arytype

  def initialize(type = nil, rank = 1, arytype = nil)
    super()
    @type = type || ValueArrayName
    @rank = rank
    @data = Array.new
    @sparse = false
    @offset = Array.new(rank, 0)
    @size = Array.new(rank, 0)
    @size_fixed = false
    @position = nil
    @arytype = arytype
  end

  def offset=(var)
    @offset = var
    @sparse = true
  end

  def add(value)
    self[*(@offset)] = value
  end

  def have_member
    !@data.empty?
  end

  def [](*idxary)
    if idxary.size != @rank
      raise ArgumentError.new("given #{idxary.size} params does not match rank: #{@rank}")
    end
    retrieve(idxary)
  end

  def []=(*idxary)
    value = idxary.slice!(-1)
    if idxary.size != @rank
      raise ArgumentError.new("given #{idxary.size} params(#{idxary}) does not match rank: #{@rank}")
    end
    idx = 0
    while idx < idxary.size
      if idxary[idx] + 1 > @size[idx]
	@size[idx] = idxary[idx] + 1
      end
      idx += 1
    end
    data = retrieve(idxary[0, idxary.size - 1])
    data[idxary.last] = value
    if value.is_a?(SOAPType)
      value.elename = ITEM_NAME
      # Sync type
      unless @type.name
	@type = XSD::QName.new(value.type.namespace,
	  SOAPArray.create_arytype(value.type.name, @rank))
      end
      value.type ||= @type
    end
    @offset = idxary
    value.parent = self if value.respond_to?(:parent=)
    offsetnext
  end

  def each
    @data.each do |data|
      yield(data)
    end
  end

  def to_a
    @data.dup
  end

  def replace
    @data = deep_map(@data) do |ele|
      yield(ele)
    end
  end

  def deep_map(ary, &block)
    ary.collect do |ele|
      if ele.is_a?(Array)
	deep_map(ele, &block)
      else
	new_obj = block.call(ele)
	new_obj.elename = ITEM_NAME
	new_obj
      end
    end
  end

  def include?(var)
    traverse_data(@data) do |v, *rank|
      if v.is_a?(SOAPBasetype) && v.data == var
	return true
      end
    end
    false
  end

  def traverse
    traverse_data(@data) do |v, *rank|
      unless @sparse
       yield(v)
      else
       yield(v, *rank) if v && !v.is_a?(SOAPNil)
      end
    end
  end

  def soap2array(ary)
    traverse_data(@data) do |v, *position|
      iteary = ary
      rank = 1
      while rank < position.size
	idx = position[rank - 1]
	if iteary[idx].nil?
	  iteary = iteary[idx] = Array.new
	else
	  iteary = iteary[idx]
	end
        rank += 1
      end
      if block_given?
	iteary[position.last] = yield(v)
      else
	iteary[position.last] = v
      end
    end
  end

  def position
    @position
  end

private

  ITEM_NAME = XSD::QName.new(nil, 'item')

  def retrieve(idxary)
    data = @data
    rank = 1
    while rank <= idxary.size
      idx = idxary[rank - 1]
      if data[idx].nil?
	data = data[idx] = Array.new
      else
	data = data[idx]
      end
      rank += 1
    end
    data
  end

  def traverse_data(data, rank = 1)
    idx = 0
    while idx < ranksize(rank)
      if rank < @rank and data[idx]
	traverse_data(data[idx], rank + 1) do |*v|
	  v[1, 0] = idx
       	  yield(*v)
	end
      else
	yield(data[idx], idx)
      end
      idx += 1
    end
  end

  def ranksize(rank)
    @size[rank - 1]
  end

  def offsetnext
    move = false
    idx = @offset.size - 1
    while !move && idx >= 0
      @offset[idx] += 1
      if @size_fixed
	if @offset[idx] < @size[idx]
	  move = true
	else
	  @offset[idx] = 0
	  idx -= 1
	end
      else
	move = true
      end
    end
  end

  def self.decode(elename, type, arytype)
    typestr, nofary = parse_type(arytype.name)
    rank = nofary.count(',') + 1
    plain_arytype = XSD::QName.new(arytype.namespace, typestr)
    o = SOAPArray.new(type, rank, plain_arytype)
    size = []
    nofary.split(',').each do |s|
      if s.empty?
	size.clear
	break
      else
	size << s.to_i
      end
    end
    unless size.empty?
      o.size = size
      o.size_fixed = true
    end
    o.elename = elename
    o
  end

  def self.create_arytype(typename, rank)
    "#{typename}[" << ',' * (rank - 1) << ']'
  end

  TypeParseRegexp = Regexp.new('^(.+)\[([\d,]*)\]$')

  def self.parse_type(string)
    TypeParseRegexp =~ string
    return $1, $2
  end
end


require 'soap/mapping/typeMap'


end
