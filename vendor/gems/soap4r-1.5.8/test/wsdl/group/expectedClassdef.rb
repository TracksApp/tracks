require 'xsd/qname'

module WSDL; module Group


# {urn:grouptype}groupele_type
#   comment - SOAP::SOAPString
#   element - SOAP::SOAPString
#   eletype - SOAP::SOAPString
#   var - SOAP::SOAPString
#   xmlattr_attr_min - SOAP::SOAPDecimal
#   xmlattr_attr_max - SOAP::SOAPDecimal
class Groupele_type
  AttrAttr_max = XSD::QName.new(nil, "attr_max")
  AttrAttr_min = XSD::QName.new(nil, "attr_min")

  attr_accessor :comment
  attr_reader :__xmlele_any
  attr_accessor :element
  attr_accessor :eletype
  attr_accessor :var

  def set_any(elements)
    @__xmlele_any = elements
  end

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_attr_min
    __xmlattr[AttrAttr_min]
  end

  def xmlattr_attr_min=(value)
    __xmlattr[AttrAttr_min] = value
  end

  def xmlattr_attr_max
    __xmlattr[AttrAttr_max]
  end

  def xmlattr_attr_max=(value)
    __xmlattr[AttrAttr_max] = value
  end

  def initialize(comment = nil, element = nil, eletype = nil, var = nil)
    @comment = comment
    @__xmlele_any = nil
    @element = element
    @eletype = eletype
    @var = var
    @__xmlattr = {}
  end
end


end; end
