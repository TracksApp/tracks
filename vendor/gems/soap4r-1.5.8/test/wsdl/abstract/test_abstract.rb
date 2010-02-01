require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module WSDL; module Abstract


class TestAbstract < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      add_rpc_method(self, 'echo', 'name', 'author')
      add_rpc_method(self, 'echoDerived', 'parameter')
      add_document_operation(
        self,
        "",
        "echoLiteral",
        [ ["in", "author", ["::SOAP::SOAPElement", "urn:www.example.org:abstract", "Author"]],
          ["out", "return", ["::SOAP::SOAPElement", "urn:www.example.org:abstract", "Book"]] ],
        { :request_style =>  :document, :request_use =>  :literal,
          :response_style => :document, :response_use => :literal,
          :faults => {} }
      )
      self.mapping_registry = AbstractMappingRegistry::EncodedRegistry
      self.literal_mapping_registry = AbstractMappingRegistry::LiteralRegistry
    end

    def echo(name, author)
      Book.new(name, author)
    end

    def echoLiteral(author)
      author
    end

    def echoDerived(parameter)
      parameter
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
      File.unlink(pathname('abstract.rb'))
      File.unlink(pathname('abstractMappingRegistry.rb'))
      File.unlink(pathname('abstractDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:www.example.org:abstract", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("abstract.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'abstractDriver.rb', 'abstract.rb', 'abstractMappingRegistry.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'abstract.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.mapping_registry = AbstractMappingRegistry::EncodedRegistry
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDERR if $DEBUG

    author = UserAuthor.new("first", "last", "uid")
    ret = @client.echo("book1", author)
    assert_equal("book1", ret.name)
    assert_equal(author.firstname, ret.author.firstname)
    assert_equal(author.lastname, ret.author.lastname)
    assert_equal(author.userid, ret.author.userid)

    author = NonUserAuthor.new("first", "last", "nonuserid")
    ret = @client.echo("book2", author)
    assert_equal("book2", ret.name)
    assert_equal(author.firstname, ret.author.firstname)
    assert_equal(author.lastname, ret.author.lastname)
    assert_equal(author.nonuserid, ret.author.nonuserid)
  end

  def test_stub
    @client = AbstractService.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG

    author = UserAuthor.new("first", "last", "uid")
    ret = @client.echo("book1", author)
    assert_equal("book1", ret.name)
    assert_equal(author.firstname, ret.author.firstname)
    assert_equal(author.lastname, ret.author.lastname)
    assert_equal(author.userid, ret.author.userid)
    #
    author = NonUserAuthor.new("first", "last", "nonuserid")
    ret = @client.echo("book2", author)
    assert_equal("book2", ret.name)
    assert_equal(author.firstname, ret.author.firstname)
    assert_equal(author.lastname, ret.author.lastname)
    assert_equal(author.nonuserid, ret.author.nonuserid)
  end

  def test_literal_stub
    @client = AbstractService.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG
    author = NonUserAuthor.new("first", "last", "nonuserid")
    ret = @client.echoLiteral(author)
    assert_equal(author.firstname, ret.firstname)
    assert_equal(author.lastname, ret.lastname)
    assert_equal(author.nonuserid, ret.nonuserid)
    assert_equal(NonUserAuthor, ret.class)
  end

  def test_stub_derived
    @client = AbstractService.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG

    parameter = DerivedClass1.new(123, "someVar1")
    ret = @client.echoDerived(parameter)
    assert_equal(123, ret.id)
    assert_equal(["someVar1"], ret.someVar1)
    assert_equal(DerivedClass1, ret.class)
  end
end


end; end
