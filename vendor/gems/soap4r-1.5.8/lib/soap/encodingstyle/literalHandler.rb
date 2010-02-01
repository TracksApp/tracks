# SOAP4R - XML Literal EncodingStyle handler library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/encodingstyle/handler'


module SOAP
module EncodingStyle


class LiteralHandler < Handler
  Namespace = SOAP::LiteralNamespace
  add_handler

  def initialize(charset = nil)
    super(charset)
    @textbuf = []
  end


  ###
  ## encode interface.
  #
  def encode_data(generator, ns, data, parent)
    attrs = {}
    name = generator.encode_name(ns, data, attrs)
    data.extraattr.each do |key, value|
      next if !@generate_explicit_type and key == XSD::AttrTypeName
      keytag = key
      if key.is_a?(XSD::QName)
        keytag = encode_attr_key(attrs, ns, key)
      end
      if value.is_a?(XSD::QName)
        value = encode_qname(attrs, ns, value)
      end
      attrs[keytag] = value
    end
    case data
    when SOAPExternalReference
      # do not encode SOAPExternalReference in
      # literalHandler (which is used for literal service)
      data.referred
    when SOAPRawString
      generator.encode_tag(name, attrs)
      generator.encode_rawstring(data.to_s)
    when XSD::XSDString
      generator.encode_tag(name, attrs)
      str = decode_str(data.to_s)
      generator.encode_string(str)
    when XSD::XSDAnySimpleType
      generator.encode_tag(name, attrs)
      generator.encode_string(data.to_s)
    when SOAPStruct
      generator.encode_tag(name, attrs)
      data.each do |key, value|
        generator.encode_child(ns, value, data)
      end
    when SOAPArray
      generator.encode_tag(name, attrs)
      data.traverse do |child, *rank|
	data.position = nil
        generator.encode_child(ns, child, data)
      end
    when SOAPElement
      unless generator.use_default_namespace
        # passes 2 times for simplifying namespace definition
        data.each do |key, value|
          if value.elename.namespace
            Generator.assign_ns(attrs, ns, value.elename.namespace)
          end
        end
      end
      if data.text and data.text.is_a?(XSD::QName)
        Generator.assign_ns(attrs, ns, data.text.namespace)
      end
      generator.encode_tag(name, attrs)
      if data.text
        if data.text.is_a?(XSD::QName)
          text = ns.name(data.text)
        else
          text = data.text
        end
        generator.encode_string(text)
      end
      data.each do |key, value|
        generator.encode_child(ns, value, data)
      end
    else
      raise EncodingStyleError.new(
        "unknown object:#{data} in this encodingStyle")
    end
  end

  def encode_data_end(generator, ns, data, parent)
    # do not encode SOAPExternalReference in
    # literalHandler (which is used for literal service)
    return nil if data.is_a?(SOAPExternalReference)
    name = generator.encode_name_end(ns, data)
    cr = (data.is_a?(SOAPCompoundtype) and data.have_member)
    generator.encode_tag_end(name, cr)
  end


  ###
  ## decode interface.
  #
  def decode_tag(ns, elename, attrs, parent)
    @textbuf.clear
    if attrs[XSD::AttrNilName] == 'true'
      o = SOAPNil.decode(elename)
    else
      o = SOAPElement.decode(elename)
    end
    if definedtype = attrs[XSD::AttrTypeName]
      o.type = ns.parse(definedtype)
    end
    o.parent = parent
    o.extraattr.update(attrs)
    decode_parent(parent, o)
    o
  end

  def decode_tag_end(ns, node)
    textbufstr = @textbuf.join
    @textbuf.clear
    o = node.node
    decode_textbuf(o, textbufstr)
  end

  def decode_text(ns, text)
    # @textbuf is set at decode_tag_end.
    @textbuf << text
  end

  def decode_prologue
  end

  def decode_epilogue
  end

  def decode_parent(parent, node)
    return unless parent.node
    case parent.node
    when SOAPElement
      parent.node.add(node)
      node.parent = parent.node
    when SOAPStruct
      parent.node.add(node.elename.name, node)
      node.parent = parent.node
    when SOAPArray
      if node.position
	parent.node[*(decode_arypos(node.position))] = node
	parent.node.sparse = true
      else
	parent.node.add(node)
      end
      node.parent = parent.node
    else
      raise EncodingStyleError.new("illegal parent: #{parent.node}")
    end
  end

private

  def decode_textbuf(node, textbufstr)
    case node
    when XSD::XSDString, SOAPElement
      if @charset
	node.set(decode_str(textbufstr))
      else
	node.set(textbufstr)
      end
    else
      # Nothing to do...
    end
  end

  def decode_str(str)
    @charset ? XSD::Charset.encoding_from_xml(str, @charset) : str
  end
end

LiteralHandler.new


end
end
