ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../app/controllers/application_controller")
require 'test_help'
require 'flexmock/test_unit' #and the flexmock gem, too!
require 'action_web_service/test_invoke'
  
module Tracks
  class Config
    def self.salt
      "change-me"
    end
  end
end

class Test::Unit::TestCase
  include AuthenticatedTestHelper

  def xml_document
    @xml_document ||= HTML::Document.new(@response.body, false, true)
  end

  def assert_xml_select(*args, &block)
    @html_document = xml_document
    assert_select(*args, &block)
  end

  def assert_error_on(model_instance, attribute, expected_error)
    actual_error = model_instance.errors.on attribute.to_sym
    assert_equal expected_error, actual_error
  end
  
  alias_method :assert_errors_on, :assert_error_on
  
  def assert_value_changed(object, method = nil)
    initial_value = object.send(method)
    yield
    assert_not_equal initial_value, object.send(method), "#{object}##{method}"
  end

end

class ActiveSupport::TestCase
   
  # Generates a random string of ascii characters (a-z, "1 0")
  # of a given length for testing assignment to fields
  # for validation purposes
  #
  def generate_random_string(length)
    string = ""
    characters = %w(a b c d e f g h i j k l m n o p q r s t u v w z y z 1\ 0)
    length.times do
      pick = characters[rand(26)]
      string << pick
    end
    return string
  end
      
  def next_week
    1.week.from_now.utc
  end
  
  # Courtesy of http://habtm.com/articles/2006/02/20/assert-yourself-man-redirecting-with-rjs
  def assert_js_redirected_to(options={}, message=nil)
   clean_backtrace do
     assert_response(:success, message)
     assert_equal 'text/javascript', @response.content_type, 'Response should be Javascript content-type';
     js_regexp = %r{(\w+://)?.*?(/|$|\\\?)(.*)}
     url_regexp = %r{^window\.location\.href [=] ['"]#{js_regexp}['"][;]$}
     redirected_to = @response.body.match(url_regexp)
     assert_not_nil(redirected_to, message)
     redirected_to = redirected_to[3]
     msg = build_message(message, "expected a JS redirect to <?>, found one to <?>", options, redirected_to)

     if options.is_a?(String)
       assert_equal(options.gsub(/^\//, ''), redirected_to, message)
     elsif options.is_a?(Regexp)
       assert(options =~ redirected_to, "#{message} #{options} #{redirected_to}")
     else
       msg = build_message(message, "response is not a redirection to all of the options supplied (redirection is <?>)", redirected_to)
       assert_equal(@controller.url_for(options).match(js_regexp)[3], redirected_to, msg)
     end
   end
  end

  def set_user_to_current_time_zone(user)
    jan_offset = Time.now.beginning_of_year.utc_offset
    jul_offset = Time.now.beginning_of_year.change(:month => 7).utc_offset
    offset = jan_offset < jul_offset ? jan_offset : jul_offset
    offset = if offset.to_s.match(/(\+|-)?(\d+):(\d+)/)
      sign = $1 == '-' ? -1 : 1
      hours, minutes = $2.to_f, $3.to_f
      ((hours * 3600) + (minutes.to_f * 60)) * sign
    elsif offset.to_f.abs <= 13
      offset.to_f * 3600
    else
      offset.to_f
    end
    zone = ActiveSupport::TimeZone.all.find{|t| t.utc_offset == offset}
    user.prefs.update_attribute(:time_zone, zone.name)
  end
end

class ActionController::IntegrationTest
  Tag #avoid errors in integration tests
  
  def assert_test_environment_ok
    assert_equal "test", ENV['RAILS_ENV']
    assert_equal "change-me", Tracks::Config.salt
  end
  
  def authenticated_post_xml(url, username, password, parameters, headers = {})
    post url,
        parameters,
        {'AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
          }.merge(headers)
  end
  
  def authenticated_get_xml(url, username, password, parameters, headers = {})
    get url,
        parameters,
        {'AUTHORIZATION' => "Basic " + Base64.encode64("#{username}:#{password}"),
          'ACCEPT' => 'application/xml',
          'CONTENT_TYPE' => 'application/xml'
          }.merge(headers)
  end
    
  def assert_response_and_body(type, body, message = nil)
    assert_equal body, @response.body, message
    assert_response type, message
  end

  def assert_response_and_body_matches(type, body_regex, message = nil)
    assert_response type, message
    assert_match body_regex, @response.body, message
  end
    
  def assert_401_unauthorized
    assert_response_and_body 401, "401 Unauthorized: You are not authorized to interact with Tracks."
  end
  
  def assert_401_unauthorized_admin
    assert_response_and_body 401, "401 Unauthorized: Only admin users are allowed access to this function."
  end
  
end
