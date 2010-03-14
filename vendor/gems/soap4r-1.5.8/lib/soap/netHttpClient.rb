# SOAP4R - net/http wrapper
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'net/http'
require 'soap/filter/filterchain'


module SOAP


class NetHttpClient

  SSLEnabled = begin
      require 'net/https'
      true
    rescue LoadError
      false
    end

  attr_reader :proxy
  attr_accessor :no_proxy
  attr_accessor :debug_dev
  attr_accessor :ssl_config		# ignored for now.
  attr_accessor :protocol_version	# ignored for now.
  attr_accessor :connect_timeout
  attr_accessor :send_timeout           # ignored for now.
  attr_accessor :receive_timeout
  attr_reader :test_loopback_response
  attr_reader :request_filter           # ignored for now.

  def initialize(proxy = nil, agent = nil)
    @proxy = proxy ? URI.parse(proxy) : nil
    @agent = agent
    @debug_dev = nil
    @test_loopback_response = []
    @request_filter = Filter::FilterChain.new
    @session_manager = SessionManager.new
    @no_proxy = @ssl_config = @protocol_version = nil
    @connect_timeout = @send_timeout = @receive_timeout = nil
  end
  
  def proxy=(proxy)
    if proxy.nil?
      @proxy = nil
    else
      if proxy.is_a?(URI)
        @proxy = proxy
      else
        @proxy = URI.parse(proxy)
      end
      if @proxy.scheme == nil or @proxy.scheme.downcase != 'http' or
	  @proxy.host == nil or @proxy.port == nil
	raise ArgumentError.new("unsupported proxy `#{proxy}'")
      end
    end
    reset_all
    @proxy
  end

  def set_auth(uri, user_id, passwd)
    raise NotImplementedError.new("auth is not supported under soap4r + net/http.")
  end

  def set_basic_auth(uri, user_id, passwd)
    # net/http does not handle url.
    @basic_auth = [user_id, passwd]
    raise NotImplementedError.new("basic_auth is not supported under soap4r + net/http.")
  end

  def set_cookie_store(filename)
    raise NotImplementedError.new
  end

  def save_cookie_store(filename)
    raise NotImplementedError.new
  end

  def reset(url)
    # no persistent connection.  ignored.
  end

  def reset_all
    # no persistent connection.  ignored.
  end

  def post(url, req_body, header = {})
    post_redirect(url, req_body, header, 10)
  end

  def get_content(url, header = {})
    if str = @test_loopback_response.shift
      return str
    end
    unless url.is_a?(URI)
      url = URI.parse(url)
    end
    extra = header.dup
    extra['User-Agent'] = @agent if @agent
    res = start(url) { |http|
	http.get(url.request_uri, extra)
      }
    res.body
  end

private

  def post_redirect(url, req_body, header, redirect_count)
    if str = @test_loopback_response.shift
      if @debug_dev
        @debug_dev << "= Request\n\n"
        @debug_dev << req_body
        @debug_dev << "\n\n= Response\n\n"
        @debug_dev << str
      end
      status = 200
      reason = nil
      contenttype = 'text/xml'
      content = str
      return Response.new(status, reason, contenttype, content)
      return str
    end
    unless url.is_a?(URI)
      url = URI.parse(url)
    end
    extra = header.dup
    extra['User-Agent'] = @agent if @agent
    res = start(url) { |http|
      if @debug_dev
        @debug_dev << "= Request\n\n"
        @debug_dev << req_body << "\n"
      end
      http.post(url.request_uri, req_body, extra)
    }
    case res
    when Net::HTTPRedirection 
      if redirect_count > 0
        post_redirect(res['location'], req_body, header,
          redirect_count - 1) 
      else
       raise ArgumentError.new("Too many redirects")
      end
    else
      Response.from_httpresponse(res)
    end
  end

  def start(url)
    http = create_connection(url)
    response = nil
    http.start { |worker|
      response = yield(worker)
      worker.finish
    }
    if @debug_dev
      @debug_dev << "\n\n= Response\n\n"
      @debug_dev << response.body << "\n"
    end
    response
  end

  def create_connection(url)
    proxy_host = proxy_port = nil
    unless no_proxy?(url)
      proxy_host = @proxy.host
      proxy_port = @proxy.port
    end
    http = Net::HTTP::Proxy(proxy_host, proxy_port).new(url.host, url.port)
    if http.respond_to?(:set_debug_output)
      http.set_debug_output(@debug_dev)
    end
    http.open_timeout = @connect_timeout if @connect_timeout
    http.read_timeout = @receive_timeout if @receive_timeout
    case url
    when URI::HTTPS then
      if SSLEnabled
	      http.use_ssl = true
      else
	      raise RuntimeError.new("Cannot connect to #{url} (OpenSSL is not installed.)")
      end
    when URI::HTTP then
      # OK
    else
      raise RuntimeError.new("Cannot connect to #{url} (Not HTTP.)")
    end
    http
  end

  NO_PROXY_HOSTS = ['localhost']

  def no_proxy?(uri)
    if !@proxy or NO_PROXY_HOSTS.include?(uri.host)
      return true
    end
    unless @no_proxy
      return false
    end
    @no_proxy.scan(/([^:,]+)(?::(\d+))?/) do |host, port|
      if /(\A|\.)#{Regexp.quote(host)}\z/i =~ uri.host &&
          (!port || uri.port == port.to_i)
        return true
      end
    end
    false
  end

  class SessionManager
    attr_accessor :connect_timeout
    attr_accessor :send_timeout
    attr_accessor :receive_timeout
  end

  class Response
    attr_reader :status
    attr_reader :reason
    attr_reader :contenttype
    attr_reader :content

    def initialize(status, reason, contenttype, content)
      @status = status
      @reason = reason
      @contenttype = contenttype
      @content = content
    end

    def self.from_httpresponse(res)
      status = res.code.to_i
      reason = res.message
      contenttype = res['content-type']
      content = res.body
      new(status, reason, contenttype, content)
    end
  end
end


end
