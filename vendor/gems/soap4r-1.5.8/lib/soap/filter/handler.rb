# SOAP4R - SOAP envelope filter base class.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP
module Filter


class Handler

  # should return envelope.  opt can be updated for other filters.
  def on_outbound(envelope, opt)
    # do something.
    envelope
  end

  # should return xml.  opt can be updated for other filters.
  def on_inbound(xml, opt)
    # do something.
    xml
  end

end


end
end
