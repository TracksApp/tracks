#!/usr/bin/env ruby
#
# It requires rails 3
#
require File.dirname(__FILE__) + "/../config/environment"
require 'rack'
require 'fcgi'

class Rack::PathInfoRewriter
	def initialize(app)
		@app = app
	end

	def call(env)
		env.delete('SCRIPT_NAME')
		parts = env['REQUEST_URI'].split('?')
		env['PATH_INFO'] = parts[0]
		env['QUERY_STRING'] = parts[1].to_s
		@app.call(env)
	end
end

Rack::Handler::FastCGI.run Rack::PathInfoRewriter.new(Tracksapp::Application)

