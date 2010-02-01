require 'xsd/qname'

module WSDL; module Anonymous


# {urn:lp}Header
#   header3 - SOAP::SOAPString
class Header
  attr_accessor :header3

  def initialize(header3 = nil)
    @header3 = header3
  end
end

# {urn:lp}ExtraInfo
class ExtraInfo < ::Array

  # {}Entry
  #   key - SOAP::SOAPString
  #   value - SOAP::SOAPString
  class Entry
    attr_accessor :key
    attr_accessor :value

    def initialize(key = nil, value = nil)
      @key = key
      @value = value
    end
  end
end

# {urn:lp}loginResponse
#   loginResult - WSDL::Anonymous::LoginResponse::LoginResult
class LoginResponse

  # inner class for member: loginResult
  # {}loginResult
  #   sessionID - SOAP::SOAPString
  class LoginResult
    attr_accessor :sessionID

    def initialize(sessionID = nil)
      @sessionID = sessionID
    end
  end

  attr_accessor :loginResult

  def initialize(loginResult = nil)
    @loginResult = loginResult
  end
end

# {urn:lp}Pack
#   header - WSDL::Anonymous::Pack::Header
class Pack

  # inner class for member: Header
  # {}Header
  #   header1 - SOAP::SOAPString
  class Header
    attr_accessor :header1

    def initialize(header1 = nil)
      @header1 = header1
    end
  end

  attr_accessor :header

  def initialize(header = nil)
    @header = header
  end
end

# {urn:lp}Envelope
#   header - WSDL::Anonymous::Envelope::Header
class Envelope

  # inner class for member: Header
  # {}Header
  #   header2 - SOAP::SOAPString
  class Header
    attr_accessor :header2

    def initialize(header2 = nil)
      @header2 = header2
    end
  end

  attr_accessor :header

  def initialize(header = nil)
    @header = header
  end
end

# {urn:lp}login
#   loginRequest - WSDL::Anonymous::Login::LoginRequest
class Login

  # inner class for member: loginRequest
  # {}loginRequest
  #   username - SOAP::SOAPString
  #   password - SOAP::SOAPString
  #   timezone - SOAP::SOAPString
  class LoginRequest
    attr_accessor :username
    attr_accessor :password
    attr_accessor :timezone

    def initialize(username = nil, password = nil, timezone = nil)
      @username = username
      @password = password
      @timezone = timezone
    end
  end

  attr_accessor :loginRequest

  def initialize(loginRequest = nil)
    @loginRequest = loginRequest
  end
end


end; end
