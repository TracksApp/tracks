require 'test/unit'
require 'soap/rpc/driver'


class TestInteropR4 < Test::Unit::TestCase
  include SOAP

  class ArrayOfBinary < Array; end
  MappingRegistry = Mapping::DefaultRegistry.dup
  MappingRegistry.add(
    ArrayOfBinary,
    SOAPArray,
    Mapping::Registry::TypedArrayFactory,
    { :type => XSD::XSDBase64Binary::Type }
  )

  class << self
    include SOAP
    def setup(name, location)
      setup_log(name)
      setup_drv(location)
    end

    def teardown
    end

  private

    def setup_log(name)
      filename = File.basename($0).sub(/\.rb$/, '') << '.log'
      @@log = File.open(filename, 'w')
      @@log << "File: #{ filename } - Wiredumps for SOAP4R client / #{ name } server.\n"
      @@log << "Date: #{ Time.now }\n\n"
    end

    def setup_drv(location)
      namespace = "http://soapinterop.org/attachments/"
      soap_action = "http://soapinterop.org/attachments/"
      @@drv = RPC::Driver.new(location, namespace, soap_action)
      @@drv.mapping_registry = MappingRegistry
      @@drv.wiredump_dev = @@log
      method_def(@@drv, soap_action)
    end

    def method_def(drv, soap_action = nil)
      drv.add_method("EchoAttachment",
	[['in', 'In', nil], ['retval', 'Out', nil]])
      drv.add_method("EchoAttachments",
	[['in', 'In', nil], ['retval', 'Out', nil]])
      drv.add_method("EchoAttachmentAsBase64",
	[['in', 'In', nil], ['retval', 'Out', nil]])
      drv.add_method("EchoBase64AsAttachment",
	[['in', 'In', nil], ['retval', 'Out', nil]])
    end
  end

  def setup
  end

  def teardown
  end

  def drv
    @@drv
  end

  def log_test
    /`([^']+)'/ =~ caller(1)[0]
    title = $1
    title = "==== " + title + " " << "=" * (title.length > 72 ? 0 : (72 - title.length))
    @@log << "#{title}\n\n"
  end

  def test_EchoAttachment
    log_test
    var = drv.EchoAttachment(Attachment.new("foobar"))
    assert_equal("foobar", var.content)
  end

  def test_EchoAttachments
    log_test
    var =  drv.EchoAttachments(
      ArrayOfBinary[
	Attachment.new("foobar"),
	Attachment.new("abc\0\0\0def"),
	Attachment.new("ghi")
      ]
    )
    assert_equal(3, var.size)
    assert_equal("foobar", var[0].content)
    assert_equal("abc\0\0\0def", var[1].content)
    assert_equal("ghi", var[2].content)
  end

  def test_EchoAttachmentAsBase64
    log_test
    var =  drv.EchoAttachmentAsBase64(Attachment.new("foobar"))
    assert_equal("foobar", var)
  end

  def test_EchoBase64AsAttachment
    log_test
    var =  drv.EchoBase64AsAttachment("abc\0\1\2def")
    assert_equal("abc\0\1\2def", var.content)
  end
end

if $0 == __FILE__
  name = ARGV.shift || 'localhost'
  location = ARGV.shift || 'http://localhost:10080/'
  TestInteropR4.setup(name, location)
end
