# SOAP4R - SOAP filter chain.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/filter/handler'


module SOAP
module Filter


class FilterChain

  def each
    @array.each do |filter|
      yield filter
    end
  end

  def reverse_each
    @array.reverse_each do |filter|
      yield filter
    end
  end

  def initialize
    @array = []
  end

  def add(filter)
    @array << filter
  end
  alias << add

  def delete(filter)
    @array.delete(filter)
  end

  def include?(filter)
    @array.include?(filter)
  end

end


end
end
