require 'test/unit'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require 'wsdl/soap/wsdl2ruby'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL
module Ref


class TestRef < Test::Unit::TestCase
  Namespace = 'urn:ref'

  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = TestRef::Namespace

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(Namespace, 'Product-Bag'),
        XSD::QName.new(Namespace, 'Creator')
      )
      self.literal_mapping_registry = ProductMappingRegistry::LiteralRegistry
    end

    def echo(arg)
      content = [
        arg.bag[0].name,
        arg.bag[0].rating,
        arg.bag[1].name,
        arg.bag[1].rating,
        arg.xmlattr_version,
        arg.xmlattr_yesno,
        arg.rating[0],
        arg.rating[1],
        arg.rating[2],
        arg.comment_1[0],
        arg.comment_1[0].xmlattr_msgid,
        arg.comment_1[1],
        arg.comment_1[1].xmlattr_msgid,
        arg.comment_2[0],
        arg.comment_2[0].xmlattr_msgid,
        arg.comment_2[1],
        arg.comment_2[1].xmlattr_msgid
      ]
      rv = Creator.new(content.join(" "))
      rv.xmlattr_Role = "role"
      rv
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_classdef
    setup_server
    @client = nil
  end

  def teardown
    teardown_server if @server
    unless $DEBUG
      File.unlink(pathname('product.rb'))
      File.unlink(pathname('productMappingRegistry.rb'))
      File.unlink(pathname('productDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("product.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'product.rb', 'productMappingRegistry.rb', 'productDriver.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def test_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("product.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['force'] = true
    TestUtil.silent do
      gen.run
    end
    compare("expectedProduct.rb", "product.rb")
    compare("expectedDriver.rb", "productDriver.rb")
  end

  def test_wsdl
    wsdl = File.join(DIR, 'product.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    p1 = e("bag")
      p1.add(e("name", "foo"))
      p1.add(e(q(Namespace, "Rating"), "0"))
    p2 = e("bag")
      p2.add(e("name", "bar"))
      p2.add(e(q(Namespace, "Rating"), "+1"))
    version = "version"
    yesno = "N"
    r1 = e(q(Namespace, "Rating"), "0")
    r2 = e(q(Namespace, "Rating"), "+1")
    r3 = e(q(Namespace, "Rating"), "-1")
    c11 = e("Comment_1", "comment11")
    c11.extraattr["msgid"] = "msgid11"
    c12 = e("Comment_1", "comment12")
    c12.extraattr["msgid"] = "msgid12"
    c21 = e("comment-2", "comment21")
    c21.extraattr["msgid"] = "msgid21"
    c22 = e("comment-2", "comment22")
    c22.extraattr["msgid"] = "msgid22"
    bag = e(q(Namespace, "Product-Bag"))
      bag.add(p1)
      bag.add(p2)
      bag.add(r1)
      bag.add(r2)
      bag.add(r3)
      bag.add(c11)
      bag.add(c12)
      bag.add(c21)
      bag.add(c22)
    bag.extraattr[q(Namespace, "version")] = version
    bag.extraattr[q(Namespace, "yesno")] = yesno
    ret = @client.echo(bag)
    assert_equal(
      [
        p1["name"].text, p1["Rating"].text,
        p2["name"].text, p2["Rating"].text,
        version, yesno,
        r1.text, r2.text, r3.text,
        c11.text, c11.extraattr["msgid"],
        c12.text, c12.extraattr["msgid"],
        c21.text, c21.extraattr["msgid"],
        c22.text, c22.extraattr["msgid"]
      ].join(" "),
      ret
    )
    assert_equal("role", ret.xmlattr_Role)
  end

  def test_wsdl_with_classdef
    wsdl = File.join(DIR, 'product.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = ProductMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    p1 = Product.new("foo", Rating::C_0)
    p2 = Product.new("bar", Rating::C_1)
    version = "version"
    yesno = Yesno::Y
    r1 = Rating::C_0
    r2 = Rating::C_1
    r3 = Rating::C_1_2
    c11 = ::SOAP::SOAPElement.new("Comment_1", "comment11")
    c11.extraattr["msgid"] = "msgid11"
    c12 = ::SOAP::SOAPElement.new("Comment_1", "comment12")
    c12.extraattr["msgid"] = "msgid12"
    c21 = Comment.new("comment21")
    c21.xmlattr_msgid = "msgid21"
    c22 = Comment.new("comment22")
    c22.xmlattr_msgid = "msgid22"
    bag = ProductBag.new([p1, p2], [r1, r2, r3], [c11, c12], [c21, c22])
    bag.xmlattr_version = version
    bag.xmlattr_yesno = yesno
    ret = @client.echo(bag)
    assert_equal(
      [
        p1.name, p1.rating,
        p2.name, p2.rating,
        version, yesno,
        r1, r2, r3,
        c11.text, c11.extraattr["msgid"],
        c12.text, c12.extraattr["msgid"],
        c21, c21.xmlattr_msgid,
        c22, c22.xmlattr_msgid
      ].join(" "),
      ret
    )
    assert_equal("role", ret.xmlattr_Role)
  end

  def test_naive
    @client = Ref_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    p1 = Product.new("foo", Rating::C_0)
    p2 = Product.new("bar", Rating::C_1)
    version = "version"
    yesno = Yesno::Y
    r1 = Rating::C_0
    r2 = Rating::C_1
    r3 = Rating::C_1_2
    c11 = ::SOAP::SOAPElement.new("Comment_1", "comment11")
    c11.extraattr["msgid"] = "msgid11"
    c12 = ::SOAP::SOAPElement.new("Comment_1", "comment12")
    c12.extraattr["msgid"] = "msgid12"
    c21 = Comment.new("comment21")
    c21.xmlattr_msgid = "msgid21"
    c22 = Comment.new("comment22")
    c22.xmlattr_msgid = "msgid22"
    pts = C__point.new("123")
    bag = ProductBag.new([p1, p2], [r1, r2, r3], [c11, c12], [c21, c22], pts)
    bag.xmlattr_version = version
    bag.xmlattr_yesno = yesno
    ret = @client.echo(bag)
    assert_equal(
      [
        p1.name, p1.rating,
        p2.name, p2.rating,
        version, yesno,
        r1, r2, r3,
        c11.text, c11.extraattr["msgid"],
        c12.text, c12.extraattr["msgid"],
        c21, c21.xmlattr_msgid,
        c22, c22.xmlattr_msgid
      ].join(" "),
      ret
    )
    assert_equal("role", ret.xmlattr_Role)
  end

  def e(name, text = nil)
    ::SOAP::SOAPElement.new(name, text)
  end

  def q(ns, name)
    XSD::QName.new(ns, name)
  end
end


end
end
