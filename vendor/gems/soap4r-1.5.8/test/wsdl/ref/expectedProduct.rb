require 'xsd/qname'

module WSDL; module Ref


# {urn:ref}Product
#   name - SOAP::SOAPString
#   rating - SOAP::SOAPString
class Product
  attr_accessor :name
  attr_accessor :rating

  def initialize(name = nil, rating = nil)
    @name = name
    @rating = rating
  end
end

# {urn:ref}Comment
#   xmlattr_msgid - SOAP::SOAPString
class Comment < ::String
  AttrMsgid = XSD::QName.new(nil, "msgid")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_msgid
    __xmlattr[AttrMsgid]
  end

  def xmlattr_msgid=(value)
    __xmlattr[AttrMsgid] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}_point
#   xmlattr_unit - SOAP::SOAPString
class C__point < ::String
  AttrUnit = XSD::QName.new(nil, "unit")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_unit
    __xmlattr[AttrUnit]
  end

  def xmlattr_unit=(value)
    __xmlattr[AttrUnit] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}Document
#   xmlattr_ID - SOAP::SOAPString
class Document < ::String
  AttrID = XSD::QName.new(nil, "ID")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_ID
    __xmlattr[AttrID]
  end

  def xmlattr_ID=(value)
    __xmlattr[AttrID] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}DerivedChoice_BaseSimpleContent
#   varStringExt - SOAP::SOAPString
#   varFloatExt - SOAP::SOAPFloat
#   xmlattr_ID - SOAP::SOAPString
#   xmlattr_attrStringExt - SOAP::SOAPString
class DerivedChoice_BaseSimpleContent < Document
  AttrAttrStringExt = XSD::QName.new(nil, "attrStringExt")
  AttrID = XSD::QName.new(nil, "ID")

  attr_accessor :varStringExt
  attr_accessor :varFloatExt

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_ID
    __xmlattr[AttrID]
  end

  def xmlattr_ID=(value)
    __xmlattr[AttrID] = value
  end

  def xmlattr_attrStringExt
    __xmlattr[AttrAttrStringExt]
  end

  def xmlattr_attrStringExt=(value)
    __xmlattr[AttrAttrStringExt] = value
  end

  def initialize(varStringExt = nil, varFloatExt = nil)
    @varStringExt = varStringExt
    @varFloatExt = varFloatExt
    @__xmlattr = {}
  end
end

# {urn:ref}Rating
class Rating < ::String
  C_0 = Rating.new("0")
  C_1 = Rating.new("+1")
  C_1_2 = Rating.new("-1")
end

# {urn:ref}Product-Bag
#   bag - WSDL::Ref::Product
#   rating - SOAP::SOAPString
#   comment_1 - WSDL::Ref::ProductBag::Comment_1
#   comment_2 - WSDL::Ref::Comment
#   m___point - WSDL::Ref::C__point
#   xmlattr_version - SOAP::SOAPString
#   xmlattr_yesno - SOAP::SOAPString
class ProductBag
  AttrVersion = XSD::QName.new("urn:ref", "version")
  AttrYesno = XSD::QName.new("urn:ref", "yesno")

  # inner class for member: Comment_1
  # {}Comment_1
  #   xmlattr_msgid - SOAP::SOAPString
  class Comment_1 < ::String
    AttrMsgid = XSD::QName.new(nil, "msgid")

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_msgid
      __xmlattr[AttrMsgid]
    end

    def xmlattr_msgid=(value)
      __xmlattr[AttrMsgid] = value
    end

    def initialize(*arg)
      super
      @__xmlattr = {}
    end
  end

  attr_accessor :bag
  attr_accessor :rating
  attr_accessor :comment_1
  attr_accessor :comment_2

  def m___point
    @v___point
  end

  def m___point=(value)
    @v___point = value
  end

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_version
    __xmlattr[AttrVersion]
  end

  def xmlattr_version=(value)
    __xmlattr[AttrVersion] = value
  end

  def xmlattr_yesno
    __xmlattr[AttrYesno]
  end

  def xmlattr_yesno=(value)
    __xmlattr[AttrYesno] = value
  end

  def initialize(bag = [], rating = [], comment_1 = [], comment_2 = [], v___point = nil)
    @bag = bag
    @rating = rating
    @comment_1 = comment_1
    @comment_2 = comment_2
    @v___point = v___point
    @__xmlattr = {}
  end
end

# {urn:ref}Creator
#   xmlattr_Role - SOAP::SOAPString
class Creator < ::String
  AttrRole = XSD::QName.new(nil, "Role")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_Role
    __xmlattr[AttrRole]
  end

  def xmlattr_Role=(value)
    __xmlattr[AttrRole] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}yesno
class Yesno < ::String
  N = Yesno.new("N")
  Y = Yesno.new("Y")
end


end; end
