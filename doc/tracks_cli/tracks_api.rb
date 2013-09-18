require 'time'
require 'net/https'

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

    def post_todo(todo)
      req = Net::HTTP::Post.new(todo_uri.path, "Content-Type" => "text/xml")
      req.basic_auth @options[:login], @options[:password]
      req.body = build_todo_body(todo)
      get_http(todo_uri).request(req)
    end

    def post_project(project)
      req = Net::HTTP::Post.new(project_uri.path, "Content-Type" => "text/xml")
      req.basic_auth @options[:login], @options[:password]
      req.body = build_project_body(project)
      get_http(project_uri).request(req)
    end

    def get_context(context_id)
      req = Net::HTTP::Get.new(context_uri_for(context_id).path)
      req.basic_auth @options[:login], @options[:password]
      get_http(context_uri_for(context_id)).request(req)
    end

    def build_todo_body(todo)
      props = "<description>#{todo[:description]}</description><project_id>#{todo[:project_id]}</project_id>"

      unless todo[:show_from].nil?
        props << "<show-from type=\"datetime\">#{Time.at(todo[:show_from]).xmlschema}</show-from>"
      end

      unless todo[:notes].nil?
        props << "<notes>#{todo[:notes]}</notes>"
      end

      unless todo[:taglist].nil?
        tags = todo[:taglist].split(",")
        if tags.length() > 0
          tags = tags.collect { |tag| "<tag><name>#{tag.strip}</name></tag>" unless tag.strip.empty?}.join('')
          props << "<tags>#{tags}</tags>"
        end
      end

      if todo[:context_name] && !todo[:context_name].empty?
        props << "<context><name>#{todo[:context_name]}</name></context>"
      else
        props << "<context_id>#{todo[:context_id]}</context_id>"
      end
      
      if todo[:is_dependend]
        props << "<predecessor_dependencies><predecessor>#{todo[:predecessor]}</predecessor></predecessor_dependencies>"
      end

      "<todo>#{props}</todo>"
    end

    def build_project_body(project)
      "<project><name>#{project[:description]}</name><default-context-id>#{project[:default_context_id]}</default-context-id></project>"
    end

  end

end