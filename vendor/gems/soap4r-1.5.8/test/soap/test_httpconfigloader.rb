require 'test/unit'
require 'soap/httpconfigloader'
require 'soap/rpc/driver'

if defined?(HTTPClient)

module SOAP


class TestHTTPConfigLoader < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    @client = SOAP::RPC::Driver.new(nil, nil)
  end

  class Request
    class Header
      attr_reader :request_uri
      def initialize(request_uri)
        @request_uri = request_uri
      end
    end

    attr_reader :header
    def initialize(request_uri)
      @header = Header.new(request_uri)
    end
  end

  def test_property
    testpropertyname = File.join(DIR, 'soapclient.properties')
    File.open(testpropertyname, "w") do |f|
      f <<<<__EOP__
protocol.http.proxy = http://myproxy:8080
protocol.http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_PEER
# depth: 1 causes an error (intentional)
protocol.http.ssl_config.verify_depth = 1
protocol.http.ssl_config.ciphers = ALL
protocol.http.basic_auth.1.url = http://www.example.com/foo1/
protocol.http.basic_auth.1.userid = user1
protocol.http.basic_auth.1.password = password1
protocol.http.basic_auth.2.url = http://www.example.com/foo2/
protocol.http.basic_auth.2.userid = user2
protocol.http.basic_auth.2.password = password2
__EOP__
    end
    begin
      @client.loadproperty(testpropertyname)
      assert_equal('ALL', @client.options['protocol.http.ssl_config.ciphers'])
      @client.options['protocol.http.basic_auth'] <<
        ['http://www.example.com/foo3/', 'user3', 'password3']
      h = @client.streamhandler.client
      basic_auth = h.www_auth.basic_auth
      cred1 = ["user1:password1"].pack('m').tr("\n", '')
      cred2 = ["user2:password2"].pack('m').tr("\n", '')
      cred3 = ["user3:password3"].pack('m').tr("\n", '')
      basic_auth.challenge(URI.parse("http://www.example.com/"), nil)
      assert_equal(cred1, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo1/baz"))))
      assert_equal(cred2, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo2/"))))
      assert_equal(cred3, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo3/baz/qux"))))
    ensure
      File.unlink(testpropertyname)
    end
  end
end


end

end
