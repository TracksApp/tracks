require 'xsd/qname'

# {urn:example.com:simpletype-rpc-type}version_struct
#   version - Version
#   msg - SOAP::SOAPString
class Version_struct
  attr_accessor :version
  attr_accessor :msg

  def initialize(version = nil, msg = nil)
    @version = version
    @msg = msg
  end
end

# {urn:example.com:simpletype-rpc-type}version
class Version < ::String
  C_16 = Version.new("1.6")
  C_18 = Version.new("1.8")
  C_19 = Version.new("1.9")
end

# {urn:example.com:simpletype-rpc-type}stateType
class StateType < ::String
  StateType = StateType.new("stateType")
end

# {urn:example.com:simpletype-rpc-type}zipIntType
class ZipIntType < ::String
  C_123 = ZipIntType.new("123")
end

# {urn:example.com:simpletype-rpc-type}zipUnion
#  any of tns:stateType tns:zipIntType
class ZipUnion < ::String
end
