# SOAP4R - SOAP Mapping header item handler
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/header/handler'
require 'soap/mapping/mapping'


module SOAP
module Header


class MappingHandler < SOAP::Header::Handler
  attr_accessor :registry

  def initialize(elename, registry = nil)
    super(elename)
    @registry = registry
  end

  # Should return an Object for mapping
  def on_mapping_outbound
    nil
  end

  # Given header is a mapped Object
  def on_mapping_inbound(obj, mustunderstand)
  end

  def on_outbound
    obj = on_mapping_outbound
    obj ? SOAP::Mapping.obj2soap(obj, @registry, @elename) : nil
  end

  def on_inbound(header, mustunderstand)
    obj = SOAP::Mapping.soap2obj(header, @registry)
    on_mapping_inbound(obj, mustunderstand)
  end
end


end
end
