require File.dirname(__FILE__) + '/test_helper'
require 'mocha'
require 'controllers/switch_environment_controller'

class SwitchEnvironmentControllerTest < Test::Unit::TestCase

  def setup
    @config = mock()
    setup_controller_test(SwitchEnvironmentController)
  end
  
  def test_index
    SeleniumOnRailsConfig.expects(:get).with(:environments).returns("hello dolly")
    get :index
    assert @response.body.include?('hello dolly')
  end
end