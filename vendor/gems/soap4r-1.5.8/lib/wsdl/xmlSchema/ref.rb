# WSDL4R - XMLSchema ref support.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module WSDL
module XMLSchema


module Ref
  def self.included(klass)
    klass.extend(RefClassSupport)
  end

  module RefClassSupport
    def attr_reader_ref(symbol)
      name = symbol.to_s
      define_method(name) {
        instance_variable_get("@#{name}") ||
          (refelement ? refelement.__send__(name) : nil)
      }
    end
  end

  attr_accessor :ref
end


end
end
