require 'net/https'
require 'minimal_test_helper'
require './doc/tracks_cli/tracks_api'

module TracksCli

  class TracksApiTest < Minitest::Test

    def test_https_detection
      uri = URI.parse("https://tracks.example.com")
      http = TracksCli::TracksAPI.new({}).get_http(uri)
      assert http.use_ssl?, "ssl expected"

      uri = URI.parse("http://tracks.example.com")
      http = TracksCli::TracksAPI.new({}).get_http(uri)
      assert !http.use_ssl?, "no ssl expected"
    end

    def test_context_uri
      uri = TracksCli::TracksAPI.new({context_prefix: "c"}).context_uri_for(16)
      assert_equal "c16.xml", uri.path

      uri = TracksCli::TracksAPI.new({context_prefix: "c"}).context_uri_for(18)
      assert_equal "c18.xml", uri.path
    end

    def test_static_uris_for_todo_and_project
      uri = TracksCli::TracksAPI.new({projects_uri: "https//tracks.example.com/projects.xml"}).project_uri
      assert_equal "https//tracks.example.com/projects.xml", uri.path

      uri = TracksCli::TracksAPI.new({uri: "https//tracks.example.com/todos.xml"}).todo_uri
      assert_equal "https//tracks.example.com/todos.xml", uri.path      
    end

  end
end