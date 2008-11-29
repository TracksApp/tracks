require 'test/unit'
require "rubygems"
require 'active_support'

for file in ["../environment.rb", "mock_view.rb"]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end

def dbg
  require 'ruby-debug'
  Debugger.start
  debugger
end

class Object
  def to_regexp
    is_a?(Regexp) ? self : Regexp.new(Regexp.escape(self.to_s))
  end
end

class Test::Unit::TestCase
  @@content_include_some = <<-EOF
  <script src="/javascripts/js_1.js?1000" type="text/javascript"></script>
  <script src="/javascripts/js_2.js?1000" type="text/javascript"></script>
  <link href="/stylesheets/css_1.css?1000" media="screen" rel="Stylesheet" type="text/css" />
  <link href="/stylesheets/css_2.css?1000" media="screen" rel="Stylesheet" type="text/css" />
  EOF
  
  # the same content, slightly changed
  @@content_include_all = @@content_include_some + <<-EOF
  <script src="/javascripts/js_3.js?1000" type="text/javascript"></script>
  <link href="/stylesheets/css_3.css?1000" media="screen" rel="Stylesheet" type="text/css" />
  EOF
  
  def public_file(filename)
    File.join(::RAILS_ROOT, "public", filename)
  end
end