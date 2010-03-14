# SOAP4R - Stream handler.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/httpconfigloader'
require 'soap/filter/filterchain'
begin
  require 'stringio'
  require 'zlib'
rescue LoadError
  warn("Loading stringio or zlib failed.  No gzipped response support.") if $DEBUG
end


module SOAP


class StreamHandler
  RUBY_VERSION_STRING = "ruby #{ RUBY_VERSION } (#{ RUBY_RELEASE_DATE }) [#{ RUBY_PLATFORM }]"

  attr_reader :filterchain

  class ConnectionData
    attr_accessor :send_string
    attr_accessor :send_contenttype
    attr_accessor :receive_string
    attr_accessor :receive_contenttype
    attr_accessor :is_fault
    attr_accessor :is_nocontent
    attr_accessor :soapaction

    def initialize(send_string = nil)
      @send_string = send_string
      @send_contenttype = nil
      @receive_string = nil
      @receive_contenttype = nil
      @is_fault = false
      @is_nocontent = false
      @soapaction = nil
    end
  end

  def initialize
    @filterchain = Filter::FilterChain.new
  end

  def self.parse_media_type(str)
    if /^#{ MediaType }(?:\s*;\s*charset=([^"]+|"[^"]+"))?$/i !~ str
      return nil
    end
    charset = $1
    charset.gsub!(/"/, '') if charset
    charset || 'us-ascii'
  end

  def self.create_media_type(charset)
    "#{ MediaType }; charset=#{ charset }"
  end

  def send(url, conn_data, soapaction = nil, charset = nil)
    # send a ConnectionData to specified url.
    # return value is a ConnectionData with receive_* property filled.
    # You can fill values of given conn_data and return it.
  end

  def reset(url = nil)
    # for initializing connection status if needed.
    # return value is not expected.
  end

  def set_wiredump_file_base(wiredump_file_base)
    # for logging.  return value is not expected.
    # Override it when you want.
    raise NotImplementedError
  end

  def test_loopback_response
    # for loopback testing.  see HTTPStreamHandler for more detail.
    # return value is an Array of loopback responses.
    # Override it when you want.
    raise NotImplementedError
  end
end


class HTTPStreamHandler < StreamHandler
  include SOAP

  begin
    require 'httpclient'
    Client = HTTPClient
    RETRYABLE = true
  rescue LoadError
    begin
      require 'http-access2'
      if HTTPAccess2::VERSION < "2.0"
        raise LoadError.new("http-access/2.0 or later is required.")
      end
      Client = HTTPAccess2::Client
      RETRYABLE = true
    rescue LoadError
      warn("Loading http-access2 failed.  Net/http is used.") if $DEBUG
      require 'soap/netHttpClient'
      Client = SOAP::NetHttpClient
      RETRYABLE = false
    end
  end

  class HttpPostRequestFilter
    def initialize(filterchain)
      @filterchain = filterchain
    end

    def filter_request(req)
      @filterchain.each do |filter|
        filter.on_http_outbound(req)
      end
    end

    def filter_response(req, res)
      @filterchain.each do |filter|
        filter.on_http_inbound(req, res)
      end
    end
  end

public
  
  attr_reader :client
  attr_accessor :wiredump_file_base
  
  MAX_RETRY_COUNT = 10       	# [times]

  def self.create(options)
    new(options)
  end

  def initialize(options)
    super()
    @client = Client.new(nil, "SOAP4R/#{ Version }")
    if @client.respond_to?(:request_filter)
      @client.request_filter << HttpPostRequestFilter.new(@filterchain)
    end
    @wiredump_file_base = nil
    @charset = @wiredump_dev = nil
    @options = options
    set_options
    @client.debug_dev = @wiredump_dev
    @cookie_store = nil
    @accept_encoding_gzip = false
  end

  def test_loopback_response
    @client.test_loopback_response
  end

  def accept_encoding_gzip=(allow)
    @accept_encoding_gzip = allow
  end

  def inspect
    "#<#{self.class}>"
  end

  def send(url, conn_data, charset = @charset)
    conn_data = send_post(url, conn_data, charset)
    @client.save_cookie_store if @cookie_store
    conn_data
  end

  def reset(url = nil)
    if url.nil?
      @client.reset_all
    else
      @client.reset(url)
    end
    @client.save_cookie_store if @cookie_store
  end

private

  def set_options
    @options["http"] ||= ::SOAP::Property.new
    HTTPConfigLoader.set_options(@client, @options["http"])
    @charset = @options["http.charset"] || XSD::Charset.xml_encoding_label
    @options.add_hook("http.charset") do |key, value|
      @charset = value
    end
    @wiredump_dev = @options["http.wiredump_dev"]
    @options.add_hook("http.wiredump_dev") do |key, value|
      @wiredump_dev = value
      @client.debug_dev = @wiredump_dev
    end
    set_cookie_store_file(@options["http.cookie_store_file"])
    @options.add_hook("http.cookie_store_file") do |key, value|
      set_cookie_store_file(value)
    end
    ssl_config = @options["http.ssl_config"]
    basic_auth = @options["http.basic_auth"]
    auth = @options["http.auth"]
    @options["http"].lock(true)
    ssl_config.unlock
    basic_auth.unlock
    auth.unlock
  end

  def set_cookie_store_file(value)
    value = nil if value and value.empty?
    @cookie_store = value
    @client.set_cookie_store(@cookie_store) if @cookie_store
  end

  def send_post(url, conn_data, charset)
    conn_data.send_contenttype ||= StreamHandler.create_media_type(charset)

    if @wiredump_file_base
      filename = @wiredump_file_base + '_request.xml'
      f = File.open(filename, "w")
      f << conn_data.send_string
      f.close
    end

    extheader = {}
    extheader['Content-Type'] = conn_data.send_contenttype
    extheader['SOAPAction'] = "\"#{ conn_data.soapaction }\""
    extheader['Accept-Encoding'] = 'gzip' if send_accept_encoding_gzip?
    send_string = conn_data.send_string
    @wiredump_dev << "Wire dump:\n\n" if @wiredump_dev
    begin
      retry_count = 0
      while true
        res = @client.post(url, send_string, extheader)
        if RETRYABLE and HTTP::Status.redirect?(res.status)
          retry_count += 1
          if retry_count >= MAX_RETRY_COUNT
            raise HTTPStreamError.new("redirect count exceeded")
          end
          url = res.header["location"][0]
          puts "redirected to #{url}" if $DEBUG
        else
          break
        end
      end
    rescue
      @client.reset(url)
      raise
    end
    @wiredump_dev << "\n\n" if @wiredump_dev
    receive_string = res.content
    if @wiredump_file_base
      filename = @wiredump_file_base + '_response.xml'
      f = File.open(filename, "w")
      f << receive_string
      f.close
    end
    case res.status
    when 405
      raise PostUnavailableError.new("#{ res.status }: #{ res.reason }")
    when 200, 202, 500
      # Nothing to do.  202 is for oneway service.
    else
      raise HTTPStreamError.new("#{ res.status }: #{ res.reason }")
    end

    # decode gzipped content, if we know it's there from the headers
    if res.respond_to?(:header) and !res.header['content-encoding'].empty? and
        res.header['content-encoding'][0].downcase == 'gzip'
      receive_string = decode_gzip(receive_string)
    # otherwise check for the gzip header
    elsif @accept_encoding_gzip && receive_string[0..1] == "\x1f\x8b"
      receive_string = decode_gzip(receive_string)
    end
    conn_data.receive_string = receive_string
    conn_data.receive_contenttype = res.contenttype
    conn_data
  end

  def send_accept_encoding_gzip?
    @accept_encoding_gzip and defined?(::Zlib)
  end

  def decode_gzip(instring)
    unless send_accept_encoding_gzip?
      raise HTTPStreamError.new("Gzipped response content.")
    end
    begin
      gz = Zlib::GzipReader.new(StringIO.new(instring))
      gz.read
    ensure
      gz.close
    end
  end
end


end
