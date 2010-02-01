require 'InteropTest.rb'

require 'soap/rpc/driver'

class InteropTestPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://dev.ctor.org/soapsrv"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    ArrayOfstring,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    ArrayOfint,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "int") }
  )
  MappingRegistry.set(
    ArrayOffloat,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "float") }
  )
  MappingRegistry.set(
    SOAPStruct,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soapinterop.org/xsd", "SOAPStruct") }
  )
  MappingRegistry.set(
    ArrayOfSOAPStruct,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soapinterop.org/xsd", "SOAPStruct") }
  )

  Methods = [
    ["echoString", "echoString",
      [
        ["in", "inputString", ["::SOAP::SOAPString"]],
        ["retval", "return", ["::SOAP::SOAPString"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStringArray", "echoStringArray",
      [
        ["in", "inputStringArray", ["String[]", "http://www.w3.org/2001/XMLSchema", "string"]],
        ["retval", "return", ["String[]", "http://www.w3.org/2001/XMLSchema", "string"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoInteger", "echoInteger",
      [
        ["in", "inputInteger", ["::SOAP::SOAPInt"]],
        ["retval", "return", ["::SOAP::SOAPInt"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoIntegerArray", "echoIntegerArray",
      [
        ["in", "inputIntegerArray", ["Integer[]", "http://www.w3.org/2001/XMLSchema", "int"]],
        ["retval", "return", ["Integer[]", "http://www.w3.org/2001/XMLSchema", "int"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoFloat", "echoFloat",
      [
        ["in", "inputFloat", ["::SOAP::SOAPFloat"]],
        ["retval", "return", ["::SOAP::SOAPFloat"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoFloatArray", "echoFloatArray",
      [
        ["in", "inputFloatArray", ["Float[]", "http://www.w3.org/2001/XMLSchema", "float"]],
        ["retval", "return", ["Float[]", "http://www.w3.org/2001/XMLSchema", "float"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStruct", "echoStruct",
      [
        ["in", "inputStruct", ["SOAPStruct", "http://soapinterop.org/xsd", "SOAPStruct"]],
        ["retval", "return", ["SOAPStruct", "http://soapinterop.org/xsd", "SOAPStruct"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStructArray", "echoStructArray",
      [
        ["in", "inputStructArray", ["SOAPStruct[]", "http://soapinterop.org/xsd", "SOAPStruct"]],
        ["retval", "return", ["SOAPStruct[]", "http://soapinterop.org/xsd", "SOAPStruct"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoVoid", "echoVoid",
      [],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoBase64", "echoBase64",
      [
        ["in", "inputBase64", ["::SOAP::SOAPBase64"]],
        ["retval", "return", ["::SOAP::SOAPBase64"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoDate", "echoDate",
      [
        ["in", "inputDate", ["::SOAP::SOAPDateTime"]],
        ["retval", "return", ["::SOAP::SOAPDateTime"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoHexBinary", "echoHexBinary",
      [
        ["in", "inputHexBinary", ["::SOAP::SOAPHexBinary"]],
        ["retval", "return", ["::SOAP::SOAPHexBinary"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoDecimal", "echoDecimal",
      [
        ["in", "inputDecimal", ["::SOAP::SOAPDecimal"]],
        ["retval", "return", ["::SOAP::SOAPDecimal"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoBoolean", "echoBoolean",
      [
        ["in", "inputBoolean", ["::SOAP::SOAPBoolean"]],
        ["retval", "return", ["::SOAP::SOAPBoolean"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |name_as, name, params, soapaction, namespace, style|
      qname = XSD::QName.new(namespace, name_as)
      if style == :document
        @proxy.add_document_method(soapaction, name, params)
        add_document_method_interface(name, params)
      else
        @proxy.add_rpc_method(qname, soapaction, name, params)
        add_rpc_method_interface(name, params)
      end
      if name_as != name and name_as.capitalize == name.capitalize
        ::SOAP::Mapping.define_singleton_method(self, name_as) do |*arg|
          __send__(name, *arg)
        end
      end
    end
  end
end

require 'soap/rpc/driver'

class InteropTestPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://dev.ctor.org/soapsrv"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    ArrayOfstring,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    ArrayOfint,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "int") }
  )
  MappingRegistry.set(
    ArrayOffloat,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "float") }
  )
  MappingRegistry.set(
    SOAPStruct,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soapinterop.org/xsd", "SOAPStruct") }
  )
  MappingRegistry.set(
    ArrayOfSOAPStruct,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soapinterop.org/xsd", "SOAPStruct") }
  )

  Methods = [
    ["echoString", "echoString",
      [
        ["in", "inputString", ["::SOAP::SOAPString"]],
        ["retval", "return", ["::SOAP::SOAPString"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStringArray", "echoStringArray",
      [
        ["in", "inputStringArray", ["String[]", "http://www.w3.org/2001/XMLSchema", "string"]],
        ["retval", "return", ["String[]", "http://www.w3.org/2001/XMLSchema", "string"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoInteger", "echoInteger",
      [
        ["in", "inputInteger", ["::SOAP::SOAPInt"]],
        ["retval", "return", ["::SOAP::SOAPInt"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoIntegerArray", "echoIntegerArray",
      [
        ["in", "inputIntegerArray", ["Integer[]", "http://www.w3.org/2001/XMLSchema", "int"]],
        ["retval", "return", ["Integer[]", "http://www.w3.org/2001/XMLSchema", "int"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoFloat", "echoFloat",
      [
        ["in", "inputFloat", ["::SOAP::SOAPFloat"]],
        ["retval", "return", ["::SOAP::SOAPFloat"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoFloatArray", "echoFloatArray",
      [
        ["in", "inputFloatArray", ["Float[]", "http://www.w3.org/2001/XMLSchema", "float"]],
        ["retval", "return", ["Float[]", "http://www.w3.org/2001/XMLSchema", "float"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStruct", "echoStruct",
      [
        ["in", "inputStruct", ["SOAPStruct", "http://soapinterop.org/xsd", "SOAPStruct"]],
        ["retval", "return", ["SOAPStruct", "http://soapinterop.org/xsd", "SOAPStruct"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoStructArray", "echoStructArray",
      [
        ["in", "inputStructArray", ["SOAPStruct[]", "http://soapinterop.org/xsd", "SOAPStruct"]],
        ["retval", "return", ["SOAPStruct[]", "http://soapinterop.org/xsd", "SOAPStruct"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoVoid", "echoVoid",
      [],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoBase64", "echoBase64",
      [
        ["in", "inputBase64", ["::SOAP::SOAPBase64"]],
        ["retval", "return", ["::SOAP::SOAPBase64"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoDate", "echoDate",
      [
        ["in", "inputDate", ["::SOAP::SOAPDateTime"]],
        ["retval", "return", ["::SOAP::SOAPDateTime"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoHexBinary", "echoHexBinary",
      [
        ["in", "inputHexBinary", ["::SOAP::SOAPHexBinary"]],
        ["retval", "return", ["::SOAP::SOAPHexBinary"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoDecimal", "echoDecimal",
      [
        ["in", "inputDecimal", ["::SOAP::SOAPDecimal"]],
        ["retval", "return", ["::SOAP::SOAPDecimal"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ],
    ["echoBoolean", "echoBoolean",
      [
        ["in", "inputBoolean", ["::SOAP::SOAPBoolean"]],
        ["retval", "return", ["::SOAP::SOAPBoolean"]]
      ],
      "http://soapinterop.org/", "http://soapinterop.org/", :rpc
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |name_as, name, params, soapaction, namespace, style|
      qname = XSD::QName.new(namespace, name_as)
      if style == :document
        @proxy.add_document_method(soapaction, name, params)
        add_document_method_interface(name, params)
      else
        @proxy.add_rpc_method(qname, soapaction, name, params)
        add_rpc_method_interface(name, params)
      end
      if name_as != name and name_as.capitalize == name.capitalize
        ::SOAP::Mapping.define_singleton_method(self, name_as) do |*arg|
          __send__(name, *arg)
        end
      end
    end
  end
end
