require 'net/https'
require File.expand_path(File.dirname(__FILE__) + '/tracks_xml_builder')

module TracksCli

  class TracksAPI
    def initialize(options)
      @options  = options
    end

    def get_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
        http.ca_path = "/etc/ssl/certs/" # Debian based path
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
      end

      http
    end

    def context_uri_for(context_id)
      URI.parse(@options[:context_prefix] + context_id.to_s + ".xml")
    end

    def todo_uri
      URI.parse(@options[:uri])
    end

    def project_uri
      URI.parse(@options[:projects_uri])
    end

    def post(uri, body)
      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "text/xml")
      req.basic_auth @options[:login], @options[:password]
      req.body = body
      get_http(uri).request(req)
    end

    def get(uri)
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth @options[:login], @options[:password]
      get_http(uri).request(req)
    end

    def post_todo(todo)
      post(todo_uri, TracksXmlBuilder.new.build_todo_xml(todo))
    end

    def post_project(project)
      post(project_uri, TracksXmlBuilder.new.build_project_xml(project))
    end

    def get_context(context_id)
      get(context_uri_for(context_id))
    end

  end

end