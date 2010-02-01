# SOAP4R - SOAP stream filter base class.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP
module Filter


class StreamHandler

  # no returning value expected.
  def on_http_outbound(req)
    # do something.
  end

  # no returning value expected.
  def on_http_inbound(req, res)
    # do something.
  end

end


end
end
