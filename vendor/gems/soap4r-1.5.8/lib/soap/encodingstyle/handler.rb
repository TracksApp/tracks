# SOAP4R - EncodingStyle handler library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/baseData'
require 'soap/element'


module SOAP
module EncodingStyle


class Handler
  @@handlers = {}

  class EncodingStyleError < Error; end

  class << self
    def uri
      self::Namespace
    end

    def handler(uri)
      @@handlers[uri]
    end

    def each
      @@handlers.each do |key, value|
	yield(value)
      end
    end

  private

    def add_handler
      @@handlers[self.uri] = self
    end
  end

  attr_reader :charset
  attr_accessor :generate_explicit_type
  def decode_typemap=(definedtypes)
    @decode_typemap = definedtypes
  end

  def initialize(charset)
    @charset = charset
    @generate_explicit_type = true
    @decode_typemap = nil
  end

  ###
  ## encode interface.
  #
  # Returns a XML instance as a string.
  def encode_data(generator, ns, data, parent)
    raise NotImplementError
  end

  def encode_data_end(generator, ns, data, parent)
    raise NotImplementError
  end

  def encode_prologue
  end

  def encode_epilogue
  end

  ###
  ## decode interface.
  #
  # Returns SOAP/OM data.
  def decode_tag(ns, name, attrs, parent)
    raise NotImplementError
  end

  def decode_tag_end(ns, name)
    raise NotImplementError
  end

  def decode_text(ns, text)
    raise NotImplementError
  end

  def decode_prologue
  end

  def decode_epilogue
  end

  def encode_attr_key(attrs, ns, qname)
    if qname.namespace.nil?
      qname.name
    else
      unless ns.assigned_as_tagged?(qname.namespace)
        Generator.assign_ns!(attrs, ns, qname.namespace)
      end
      ns.name_attr(qname)
    end
  end

  def encode_qname(attrs, ns, qname)
    if qname.namespace.nil?
      qname.name
    else
      Generator.assign_ns(attrs, ns, qname.namespace)
      ns.name(qname)
    end
  end
end


end
end
