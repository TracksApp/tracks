# SOAP4R - attribute proxy interface.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP


module AttrProxy
  def self.included(klass)
    klass.extend(AttrProxyClassSupport)
  end

  module AttrProxyClassSupport
    def attr_proxy(symbol, assignable = false)
      name = symbol.to_s
      define_method(name) {
        attrproxy.__send__(name)
      }
      if assignable
        aname = name + '='
        define_method(aname) { |rhs|
          attrproxy.__send__(aname, rhs)
        }
      end
    end
  end
end


end
