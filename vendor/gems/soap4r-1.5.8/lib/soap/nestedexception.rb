# SOAP4R - Nested exception implementation
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP


module NestedException
  attr_reader :cause
  attr_reader :original_backtraace

  def initialize(msg = nil, cause = nil)
    super(msg)
    @cause = cause
    @original_backtrace = nil
  end

  def set_backtrace(backtrace)
    if @cause and @cause.respond_to?(:backtrace)
      @original_backtrace = backtrace
=begin
      # for agressive backtrace abstraction: 'here' only should not be good
      here = @original_backtrace[0]
      backtrace = Array[*@cause.backtrace]
      backtrace[0] = "#{backtrace[0]}: #{@cause} (#{@cause.class})"
      backtrace.unshift(here)
=end
      # just join the nested backtrace at the tail of backtrace
      caused = Array[*@cause.backtrace]
      caused[0] = "#{caused[0]}: #{@cause} (#{@cause.class}) [NESTED]"
      backtrace += caused
    end
    super(backtrace)
  end
end


end
