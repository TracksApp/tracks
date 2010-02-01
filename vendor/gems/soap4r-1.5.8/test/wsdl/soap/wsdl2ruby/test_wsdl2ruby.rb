require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', 'testutil.rb')


module WSDL; module SOAP


class TestWSDL2Ruby < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    Dir.chdir(DIR) do
      gen = WSDL::SOAP::WSDL2Ruby.new
      gen.location = pathname("rpc.wsdl")
      gen.basedir = DIR
      gen.logger.level = Logger::FATAL
      gen.opt['classdef'] = nil
      gen.opt['client_skelton'] = nil
      gen.opt['servant_skelton'] = nil
      gen.opt['cgi_stub'] = nil
      gen.opt['standalone_server_stub'] = nil
      gen.opt['mapping_registry'] = nil
      gen.opt['driver'] = nil
      gen.opt['force'] = true
      TestUtil.silent do
        gen.run
      end
    end
  end

  def teardown
    # leave generated file for debug.
  end

  def test_rpc
    compare("expectedServant.rb", "echo_versionServant.rb")
    compare("expectedClassdef.rb", "echo_version.rb")
    compare("expectedService.rb", "echo_version_service.rb")
    compare("expectedService.cgi", "echo_version_service.cgi")
    compare("expectedMappingRegistry.rb", "echo_versionMappingRegistry.rb")
    compare("expectedDriver.rb", "echo_versionDriver.rb")
    compare("expectedClient.rb", "echo_version_serviceClient.rb")

    File.unlink(pathname("echo_versionServant.rb"))
    File.unlink(pathname("echo_version.rb"))
    File.unlink(pathname("echo_version_service.rb"))
    File.unlink(pathname("echo_version_service.cgi"))
    File.unlink(pathname("echo_versionMappingRegistry.rb"))
    File.unlink(pathname("echo_versionDriver.rb"))
    File.unlink(pathname("echo_version_serviceClient.rb"))
  end

private

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end
