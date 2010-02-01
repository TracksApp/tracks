require 'xsd/qname'

module WSDL; module Any


# {urn:example.com:echo-type}foo.bar
#   before - SOAP::SOAPString
#   after - SOAP::SOAPString
class FooBar
  attr_accessor :before
  attr_reader :__xmlele_any
  attr_accessor :after

  def set_any(elements)
    @__xmlele_any = elements
  end

  def initialize(before = nil, after = nil)
    @before = before
    @__xmlele_any = nil
    @after = after
  end
end

# {urn:example.com:echo-type}setOutputAndCompleteRequest
#   taskId - SOAP::SOAPString
#   data - WSDL::Any::SetOutputAndCompleteRequest::C_Data
#   participantToken - SOAP::SOAPString
class SetOutputAndCompleteRequest

  # inner class for member: data
  # {}data
  class C_Data
    attr_reader :__xmlele_any

    def set_any(elements)
      @__xmlele_any = elements
    end

    def initialize
      @__xmlele_any = nil
    end
  end

  attr_accessor :taskId
  attr_accessor :data
  attr_accessor :participantToken

  def initialize(taskId = nil, data = nil, participantToken = nil)
    @taskId = taskId
    @data = data
    @participantToken = participantToken
  end
end


end; end
