ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "test" unless defined?(RAILS_ROOT)
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
gem 'activesupport'
require 'active_support'

gem 'actionpack'
require 'action_view/template_handler'
require 'action_view/template_handlers/builder'
require 'action_view/template_handlers/erb'
require 'action_view/template_handlers/rjs'
require 'action_view/base'
require 'action_view/partials'
require 'action_view/template_error'
require 'action_controller'

require 'selenium_on_rails/suite_renderer'
require 'selenium_on_rails/fixture_loader'
require 'selenium_helper'
require 'controllers/selenium_controller'
require File.expand_path(File.dirname(__FILE__) + "/../routes")
require 'action_controller/test_process'

SeleniumController.append_view_path File.expand_path(File.dirname(__FILE__))

def setup_controller_test(controller)
  @controller = controller.new
  ActionController::Routing::Routes.draw
  @request    = ActionController::TestRequest.new
  @response   = ActionController::TestResponse.new
end


class SeleniumController
  attr_accessor :layout_override
  # Re-raise errors caught by the controller.
  def rescue_action e
    raise e
  end
      
  def render options = nil
    if override_layout? options
      options[:layout] = false
      super options
      return response.body = @layout_override.gsub('@content_for_layout', response.body)
    end
    super options
  end
  
  private
    def override_layout? options
      return false unless @layout_override
      if options[:action] or options[:template]
        options[:layout] != false #for action and template the default layout is used if not explicitly disabled
      else
        not [nil, false].include? options[:layout] #otherwise a layout has to be specified
      end
    end

end

class Test::Unit::TestCase
  def assert_text_equal expected, actual
    assert_equal clean_text(expected), clean_text(actual)
  end
  
  def clean_text text
    text.gsub("\t", '  ').gsub("\r", '').gsub("\n", '').gsub(/ *</, '<')
  end
  
end

module SeleniumOnRails::PathsTestHelper
  def selenium_tests_path
    File.expand_path(File.dirname(__FILE__) + '/../test_data')
  end
end

class TestView < ActionView::Base
  include SeleniumOnRails::PartialsSupport
  
  # alias_method :render_partial_without_override, :render_partial
  # def render_partial partial_path = default_template_name, object = nil, local_assigns = nil, status = nil
  #   if @override
  #     partial = render :inline => @override, :type => @override_type, :locals => local_assigns
  #     extract_commands_from_partial partial
  #   else
  #     render_partial_without_override partial_path, object, local_assigns, status
  #   end
  # end
  # 
  # def override_partial partial, type
  #   @override, @override_type = partial, type
  #   result = yield
  #   @override, @override_type = nil, nil
  #   result
  # end
  
end