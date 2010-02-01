require 'test/unit'
require 'soap/rpc/driver'
require 'webrick'
require 'logger'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'testutil.rb')


module SOAP


class TestCookie < Test::Unit::TestCase
  Port = 17171

  class CookieFilter < SOAP::Filter::StreamHandler
    attr_accessor :cookie_value

    def initialize
      @cookie_value = nil
    end

    def on_http_outbound(req)
      if @cookie_value
        req.header.delete('Cookie')
        req.header['Cookie'] = @cookie_value
      end
    end

    def on_http_inbound(req, res)
      # this sample filter only caputures the first cookie.
      cookie = res.header['Set-Cookie'][0]
      cookie.sub!(/;.*\z/, '') if cookie
      @cookie_value = cookie
      # do not save cookie value.
    end
  end

  def setup
    @logger = Logger.new(STDERR)
    @logger.level = Logger::Severity::ERROR
    @url = "http://localhost:#{Port}/"
    @server = @client = nil
    @server_thread = nil
    setup_server
    setup_client
  end

  def teardown
    teardown_client if @client
    teardown_server if @server
  end

  def setup_server
    @server = WEBrick::HTTPServer.new(
      :BindAddress => "0.0.0.0",
      :Logger => @logger,
      :Port => Port,
      :AccessLog => [],
      :DocumentRoot => File.dirname(File.expand_path(__FILE__))
    )
    @server.mount(
      '/',
      WEBrick::HTTPServlet::ProcHandler.new(method(:do_server_proc).to_proc)
    )
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_client
    @client = SOAP::RPC::Driver.new(@url, '')
    @client.add_method("do_server_proc")
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def teardown_client
    @client.reset_stream
  end

  def do_server_proc(req, res)
    cookie = req['Cookie'].to_s
    cookie = "var=hello world" if cookie.empty?
    res['content-type'] = 'text/xml'
    res['Set-Cookie'] = cookie
    res.body = <<__EOX__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:do_server_proc xmlns:n1="urn:foo" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return xsi:nil="true"/>
    </n1:do_server_proc>
  </env:Body>
</env:Envelope>
__EOX__
  end

  def test_normal
    @client.wiredump_dev = STDOUT if $DEBUG
    filter = CookieFilter.new
    @client.streamhandler.filterchain << filter
    assert_nil(@client.do_server_proc)
    assert_equal('var=hello world', filter.cookie_value)
    filter.cookie_value = 'var=empty'
    assert_nil(@client.do_server_proc)
    assert_equal('var=empty', filter.cookie_value)
  end
end


end
