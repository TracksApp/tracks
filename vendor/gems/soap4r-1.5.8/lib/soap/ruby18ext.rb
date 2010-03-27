# SOAP4R - Extensions for Ruby 1.8.X compatibility
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.
# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

unless RUBY_VERSION >= "1.9.0"
  class Hash
    def key(value)
      index(value)
    end
  end
end