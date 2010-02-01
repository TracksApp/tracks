#!/usr/bin/env ruby

require 'getoptlong'
require 'logger'
require 'wsdl/xmlSchema/xsd2ruby'


class XSD2RubyApp < Logger::Application
private

  OptSet = [
    ['--xsd','-x', GetoptLong::REQUIRED_ARGUMENT],
    ['--module_path','-m', GetoptLong::REQUIRED_ARGUMENT],
    ['--classdef','-e', GetoptLong::OPTIONAL_ARGUMENT],
    ['--mapping_registry','-r', GetoptLong::NO_ARGUMENT],
    ['--mapper','-p', GetoptLong::NO_ARGUMENT],
    ['--force','-f', GetoptLong::NO_ARGUMENT],
    ['--quiet','-q', GetoptLong::NO_ARGUMENT],
  ]

  def initialize
    super('app')
    STDERR.sync = true
    self.level = Logger::FATAL
  end

  def run
    @worker = WSDL::XMLSchema::XSD2Ruby.new
    @worker.logger = @log
    location, opt = parse_opt(GetoptLong.new(*OptSet))
    usage_exit unless location
    @worker.location = location
    if opt['quiet']
      self.level = Logger::FATAL
    else
      self.level = Logger::INFO
    end
    @worker.opt.update(opt)
    @worker.run
    0
  end

  def usage_exit
    puts <<__EOU__
Usage: #{ $0 } --xsd xsd_location [options]
  xsd_location: filename or URL

Example:
  #{ $0 } --xsd myapp.xsd --classdef foo

Options:
  --xsd xsd_location
  --classdef [filenameprefix]
  --mapping_registry
  --mapper
  --module_path [Module::Path::Name]
  --force
  --quiet
__EOU__
    exit 1
  end

  def parse_opt(getoptlong)
    opt = {}
    xsd = nil
    begin
      getoptlong.each do |name, arg|
	case name
	when "--xsd"
	  xsd = arg
        when "--module_path"
          opt['module_path'] = arg
	when "--classdef", "--mapping_registry", "--mapper"
	  opt[name.sub(/^--/, '')] = arg.empty? ? nil : arg
	when "--force"
	  opt['force'] = true
        when "--quiet"
          opt['quiet'] = true
	else
	  raise ArgumentError.new("Unknown type #{ arg }")
	end
      end
    rescue
      usage_exit
    end
    return xsd, opt
  end
end

XSD2RubyApp.new.start
