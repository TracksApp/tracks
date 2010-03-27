# SOAP4R - SOAP XML Instance Generator library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/ns'
require 'soap/baseData'
require 'soap/encodingstyle/handler'
require 'xsd/codegen/gensupport'


module SOAP


###
## CAUTION: MT-unsafe
#
class Generator
  include SOAP
  include XSD::CodeGen::GenSupport

  class FormatEncodeError < Error; end

public

  attr_accessor :charset
  attr_accessor :default_encodingstyle
  attr_accessor :generate_explicit_type
  attr_accessor :use_numeric_character_reference
  attr_accessor :use_default_namespace

  def initialize(opt = {})
    @reftarget = nil
    @handlers = {}
    @charset = opt[:charset] || XSD::Charset.xml_encoding_label
    @default_encodingstyle = opt[:default_encodingstyle] || EncodingNamespace
    @generate_explicit_type =
      opt.key?(:generate_explicit_type) ? opt[:generate_explicit_type] : true
    @use_default_namespace = opt[:use_default_namespace]
    @attributeformdefault = opt[:attributeformdefault]
    @use_numeric_character_reference = opt[:use_numeric_character_reference]
    @indentstr = opt[:no_indent] ? '' : '  '
    @buf = @indent = @curr = nil
    @default_ns = opt[:default_ns]
    @default_ns_tag = opt[:default_ns_tag]
  end

  def generate(obj, io = nil)
    @buf = io || ''
    @indent = ''
    @encode_char_regexp = get_encode_char_regexp()

    prologue
    @handlers.each do |uri, handler|
      handler.encode_prologue
    end

    ns = SOAP::NS.new
    if @default_ns
      @default_ns.each_ns do |default_ns, default_tag|
        Generator.assign_ns(obj.extraattr, ns, default_ns, default_tag)
      end
    end
    if @default_ns_tag
      @default_ns_tag.each_ns do |default_ns, default_tag|
        ns.known_tag[default_ns] = default_tag
      end
    end
    @buf << xmldecl
    encode_data(ns, obj, nil)

    @handlers.each do |uri, handler|
      handler.encode_epilogue
    end
    epilogue

    @buf
  end

  def encode_data(ns, obj, parent)
    if obj.respond_to?(:to_xmlpart)
      formatted = trim_eol(obj.to_xmlpart)
      formatted = trim_indent(formatted)
      formatted = formatted.gsub(/^/, @indent).sub(/\n+\z/, '')
      @buf << "\n#{formatted}"
      return
    elsif obj.is_a?(SOAPEnvelopeElement)
      encode_element(ns, obj, parent)
      return
    end
    if @reftarget && !obj.precedents.empty?
      add_reftarget(obj.elename.name, obj)
      ref = SOAPReference.new(obj)
      ref.elename = ref.elename.dup_name(obj.elename.name)
      obj.precedents.clear	# Avoid cyclic delay.
      obj.encodingstyle = parent.encodingstyle
      # SOAPReference is encoded here.
      obj = ref
    end
    encodingstyle = obj.encodingstyle
    # Children's encodingstyle is derived from its parent.
    encodingstyle ||= parent.encodingstyle if parent
    obj.encodingstyle = encodingstyle
    handler = find_handler(encodingstyle || @default_encodingstyle)
    unless handler
      raise FormatEncodeError.new("Unknown encodingStyle: #{ encodingstyle }.")
    end
    if !obj.elename.name
      raise FormatEncodeError.new("Element name not defined: #{ obj }.")
    end
    handler.encode_data(self, ns, obj, parent)
    handler.encode_data_end(self, ns, obj, parent)
  end

  def add_reftarget(name, node)
    unless @reftarget
      raise FormatEncodeError.new("Reftarget is not defined.")
    end
    @reftarget.add(name, node)
  end

  def encode_child(ns, child, parent)
    indent_backup, @indent = @indent, @indent + @indentstr
    encode_data(ns.clone_ns, child, parent)
    @indent = indent_backup
  end

  def encode_element(ns, obj, parent)
    attrs = obj.extraattr
    if obj.is_a?(SOAPBody)
      @reftarget = obj
      obj.encode(self, ns, attrs) do |child|
	indent_backup, @indent = @indent, @indent + @indentstr
        encode_data(ns.clone_ns, child, obj)
	@indent = indent_backup
      end
      @reftarget = nil
    else
      if obj.is_a?(SOAPEnvelope)
        Generator.assign_ns(attrs, ns, XSD::InstanceNamespace)
        Generator.assign_ns(attrs, ns, XSD::Namespace)
      end
      obj.encode(self, ns, attrs) do |child|
	indent_backup, @indent = @indent, @indent + @indentstr
        encode_data(ns.clone_ns, child, obj)
	@indent = indent_backup
      end
    end
  end

  def encode_name(ns, data, attrs)
    if element_local?(data)
      data.elename.name
    else
      if @use_default_namespace
        Generator.assign_ns(attrs, ns, data.elename.namespace, '')
      else
        Generator.assign_ns(attrs, ns, data.elename.namespace)
      end
      ns.name(data.elename)
    end
  end

  def encode_name_end(ns, data)
    if element_local?(data)
      data.elename.name
    else
      ns.name(data.elename)
    end
  end

  def encode_tag(elename, attrs = nil)
    if attrs.nil? or attrs.empty?
      @buf << "\n#{ @indent }<#{ elename }>"
      return 
    end
    ary = []
    attrs.each do |key, value|
      ary << %Q[#{ key }="#{ get_encoded(value.to_s) }"]
    end
    case ary.size
    when 0
      @buf << "\n#{ @indent }<#{ elename }>"
    when 1
      @buf << %Q[\n#{ @indent }<#{ elename } #{ ary[0] }>]
    else
      @buf << "\n#{ @indent }<#{ elename } " <<
        ary.join("\n#{ @indent }#{ @indentstr * 2 }") <<
	'>'
    end
  end

  def encode_tag_end(elename, cr = nil)
    if cr
      @buf << "\n#{ @indent }</#{ elename }>"
    else
      @buf << "</#{ elename }>"
    end
  end

  def encode_rawstring(str)
    @buf << str
  end

  def encode_string(str)
    @buf << get_encoded(str)
  end

  def element_local?(element)
    element.elename.namespace.nil?
  end

  def self.assign_ns(attrs, ns, namespace, tag = nil)
    if namespace.nil?
      raise FormatEncodeError.new("empty namespace")
    end
    override_default_ns = (tag == '' and namespace != ns.default_namespace)
    if override_default_ns or !ns.assigned?(namespace)
      assign_ns!(attrs, ns, namespace, tag)
    end
  end

  def self.assign_ns!(attrs, ns, namespace, tag = nil)
    tag = ns.assign(namespace, tag)
    if tag == ''
      attr = 'xmlns'
    else
      attr = "xmlns:#{tag}"
    end
    attrs[attr] = namespace
  end

private

  def prologue
  end

  def epilogue
  end

  ENCODE_CHAR_REGEXP = {}

  EncodeMap = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    '\'' => '&apos;',
    "\r" => '&#xd;'
  }

  def get_encoded(str)
    if @use_numeric_character_reference and !XSD::Charset.is_us_ascii(str)
      str.gsub!(@encode_char_regexp) { |c| EncodeMap[c] }
      str.unpack("U*").collect { |c|
        if c == 0x9 or c == 0xa or c == 0xd or (c >= 0x20 and c <= 0x7f)
          c.chr
        else
          sprintf("&#x%x;", c)
        end
      }.join
    else
      str.gsub(@encode_char_regexp) { |c| EncodeMap[c] }
    end
  end

  def get_encode_char_regexp
    ENCODE_CHAR_REGEXP[XSD::Charset.encoding] ||=
      Regexp.new("[#{EncodeMap.keys.join}]")
  end

  def find_handler(encodingstyle)
    unless @handlers.key?(encodingstyle)
      factory = SOAP::EncodingStyle::Handler.handler(encodingstyle)
      if factory
        handler = factory.new(@charset)
        handler.generate_explicit_type = @generate_explicit_type
        handler.encode_prologue
        @handlers[encodingstyle] = handler
      end
    end
    @handlers[encodingstyle]
  end

  def xmldecl
    if @charset
      %Q[<?xml version="1.0" encoding="#{ @charset }" ?>]
    else
      %Q[<?xml version="1.0" ?>]
    end
  end
end


end
