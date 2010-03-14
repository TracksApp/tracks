# XSD4R - XMLParser XML parser library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/xmlparser'
require 'xml/libxml'


module XSD
module XMLParser


class LibXMLParser < XSD::XMLParser::Parser
  include XML::SaxParser::Callbacks

  def do_parse(string_or_readable)
    if string_or_readable.respond_to?(:read)
      string = string_or_readable.read
    else
      string = string_or_readable
    end
    # XMLParser passes a String in utf-8.
    @charset = 'utf-8'
    @parser = XML::SaxParser.string(string)
    @parser.callbacks = self
    @parser.parse
  end
  
  ENTITY_REF_MAP = {
    'lt' => '<',
    'gt' => '>',
    'amp' => '&',
    'quot' => '"',
    'apos' => '\''
  }

  #def on_internal_subset(name, external_id, system_id)
  #  nil
  #end

  #def on_is_standalone()
  #  nil
  #end

  #def on_has_internal_subset()
  #  nil
  #end

  #def on_has_external_subset()
  #  nil
  #end

  #def on_start_document()
  #  nil
  #end

  #def on_end_document()
  #  nil
  #end
  
  def on_start_element_ns(name, attributes, prefix, uri, namespaces)
    name = "#{prefix}:#{name}" unless prefix.nil?
    namespaces.each do |key,value|
      nsprefix = key.nil? ? "xmlns" : "xmlns:#{key}"
      attributes[nsprefix] = value
    end
    start_element(name, attributes)
  end

  def on_end_element(name)
    end_element(name)
  end

  def on_reference(name)
    characters(ENTITY_REF_MAP[name])
  end

  def on_characters(chars)
    characters(chars)
  end

  #def on_processing_instruction(target, data)
  #  nil
  #end

  #def on_comment(msg)
  #  nil
  #end

  def on_parser_warning(msg)
    warn(msg)
  end

  def on_parser_error(msg)
    raise ParseError.new(msg)
  end

  def on_parser_fatal_error(msg)
    raise ParseError.new(msg)
  end

  def on_cdata_block(cdata)
    characters(cdata)
  end

  def on_external_subset(name, external_id, system_id)
    nil
  end

  add_factory(self)
end


end
end
