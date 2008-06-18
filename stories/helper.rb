ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
$:.unshift File.join(File.dirname(__FILE__), *%w[.. vendor plugings rspec lib])
require 'test_help'
require 'test/unit/testresult'
require 'spec'
require 'spec/rails'
require 'spec/story'
require 'webrat/selenium'

module Spec
  module Story
    class StepGroup
      def include_steps_for(name)
        require File.expand_path(File.dirname(__FILE__) + "/steps/#{name}")
        step_matchers = rspec_story_steps[name.to_sym]
        warn "WARNING: 0 step matchers found for include_steps_for(:#{name}). Are you missing an include?" if step_matchers.empty?
        self << step_matchers
      end
    end
  end
end

Test::Unit.run = true

class SeleniumRailsStory < Test::Unit::TestCase
  include Spec::Matchers
  include Spec::Rails::Matchers

  def initialize #:nodoc:
    # TODO - eliminate this hack, which is here to stop
    # Rails Stories from dumping the example summary.
    Spec::Runner::Options.class_eval do
      def examples_should_be_run?
        false
      end
    end
        
    @_result = Test::Unit::TestResult.new
  end
  
  def should_see(text_or_regexp)
    if text_or_regexp.is_a?(Regexp)
      response.should have_tag("*", text_or_regexp)
    else
      response.should have_tag("*", /#{Regexp.escape(text_or_regexp)}/i)
    end
  end
  
  def response
    webrat_session.response_body
  end
  
  def method_missing(name, *args)
    if webrat_session.respond_to?(name)
      webrat_session.send(name, *args)
    else
      super
    end
  end
    
protected
  
  def webrat_session    
    @webrat_session ||= begin
      Webrat::SeleniumSession.new(SeleniumDriverManager.instance.running_selenium_driver)
    end
  end
end

class DatabaseResetListener
  include Singleton
  def scenario_started(*args)
    if defined?(ActiveRecord::Base)
      connection = ActiveRecord::Base.connection 
      %w[users].each do |table|
        connection.execute "DELETE FROM #{table}" 
      end
    end
  end

  def scenario_succeeded(*args)
  end
  alias :scenario_pending :scenario_succeeded
  alias :scenario_failed :scenario_succeeded
end

class CookieResetListener
  include Singleton
  def scenario_started(*args)
    %w[tracks_login auth_token _session_id].each do |cookie_name|
      SeleniumDriverManager.instance.running_selenium_driver.get_eval("window.document.cookie = '#{cookie_name}=;expires=Thu, 01-Jan-1970 00:00:01 GMT; path=/';")
    end
  end
  
  def scenario_succeeded(*args)
  end
  alias :scenario_pending :scenario_succeeded
  alias :scenario_failed :scenario_succeeded
end

class Spec::Story::Runner::ScenarioRunner
  def initialize
    @listeners = [DatabaseResetListener.instance, CookieResetListener.instance]
  end
end

class Spec::Story::GivenScenario
  def perform(instance, name = nil)
    scenario = Spec::Story::Runner::StoryRunner.scenario_from_current_story @name
    runner = Spec::Story::Runner::ScenarioRunner.new
    runner.instance_variable_set(:@listeners,[])
    runner.run(scenario, instance)
  end
end
