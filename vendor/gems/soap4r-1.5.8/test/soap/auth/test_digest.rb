require 'test/unit'
require 'soap/rpc/driver'
require 'webrick'
require 'webrick/httpproxy'
require 'logger'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


module SOAP; module Auth


class TestDigest < Test::Unit::TestCase
  Port = 17171
  ProxyPort = 17172

  def setup
    @logger = Logger.new(STDERR)
    @logger.level = Logger::Severity::FATAL
    @url = "http://localhost:#{Port}/"
    @proxyurl = "http://localhost:#{ProxyPort}/"
    @server = @proxyserver = @client = nil
    @server_thread = @proxyserver_thread = nil
    setup_server
    setup_client
  end

  def teardown
    teardown_client if @client
    teardown_proxyserver if @proxyserver
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
    htdigest = File.join(File.dirname(__FILE__), 'htdigest')
    htdigest_userdb = WEBrick::HTTPAuth::Htdigest.new(htdigest)
    @digest_auth = WEBrick::HTTPAuth::DigestAuth.new(
      :Logger => @logger,
      :Algorithm => 'MD5',
      :Realm => 'auth',
      :UserDB => htdigest_userdb
    )
    @server.mount(
      '/',
      WEBrick::HTTPServlet::ProcHandler.new(method(:do_server_proc).to_proc)
    )
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_proxyserver
    @proxyserver = WEBrick::HTTPProxyServer.new(
      :BindAddress => "0.0.0.0",
      :Logger => @logger,
      :Port => ProxyPort,
      :AccessLog => []
    )
    @proxyserver_thread = TestUtil.start_server_thread(@proxyserver)
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

  def teardown_proxyserver
    @proxyserver.shutdown
    @proxyserver_thread.kill
    @proxyserver_thread.join
  end

  def teardown_client
    @client.reset_stream
  end

  def do_server_proc(req, res)
    @digest_auth.authenticate(req, res)
    res['content-type'] = 'text/xml'
    res.body = <<__EOX__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:do_server_proc xmlns:n1="urn:foo" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return>OK</return>
    </n1:do_server_proc>
  </env:Body>
</env:Envelope>
__EOX__
  end

  def test_direct
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.options["protocol.http.auth"] << [@url, "admin", "admin"]
    assert_equal("OK", @client.do_server_proc)
  end

  def test_proxy
    setup_proxyserver
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.options["protocol.http.proxy"] = @proxyurl
    @client.options["protocol.http.auth"] << [@url, "guest", "guest"]
    assert_equal("OK", @client.do_server_proc)
  end
end


end; end
